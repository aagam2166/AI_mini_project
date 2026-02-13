from fastapi import FastAPI, Depends, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy.orm import Session
import json

from .db import Base, engine, get_db
from . import models, schemas, crud
from .services.optimizer import ApplianceVar, baseline_schedule, optimize_csp, build_tou_tariff

Base.metadata.create_all(bind=engine)

app = FastAPI(title="IntelliHEMS API", version="1.0.0")

# allow Flutter dev
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # tighten for prod
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/health")
def health():
    return {"ok": True}

# ---------- Appliances ----------
@app.get("/appliances", response_model=list[schemas.ApplianceOut])
def list_appliances(db: Session = Depends(get_db)):
    return crud.list_appliances(db)

@app.post("/appliances", response_model=schemas.ApplianceOut)
def add_appliance(data: schemas.ApplianceCreate, db: Session = Depends(get_db)):
    return crud.create_appliance(db, data)

@app.patch("/appliances/{appliance_id}", response_model=schemas.ApplianceOut)
def patch_appliance(appliance_id: int, data: schemas.ApplianceUpdate, db: Session = Depends(get_db)):
    a = crud.update_appliance(db, appliance_id, data)
    if not a:
        raise HTTPException(status_code=404, detail="Appliance not found")
    return a

@app.delete("/appliances/{appliance_id}")
def remove_appliance(appliance_id: int, db: Session = Depends(get_db)):
    ok = crud.delete_appliance(db, appliance_id)
    if not ok:
        raise HTTPException(status_code=404, detail="Appliance not found")
    return {"deleted": True}

# ---------- Preferences ----------
@app.get("/preferences", response_model=schemas.PreferencesOut)
def get_preferences(db: Session = Depends(get_db)):
    return crud.get_preferences(db)

@app.put("/preferences", response_model=schemas.PreferencesOut)
def update_preferences(data: schemas.PreferencesIn, db: Session = Depends(get_db)):
    return crud.update_preferences(db, data)

# ---------- Optimize ----------
@app.post("/optimize", response_model=schemas.OptimizeResponse)
def run_optimize(req: schemas.OptimizeRequest, db: Session = Depends(get_db)):
    prefs = crud.get_preferences(db)
    appliances = [a for a in crud.list_appliances(db) if a.enabled]

    vars_ = [
        ApplianceVar(
            id=a.id,
            name=a.name,
            power_w=a.power_w,
            duration_min=a.duration_min,
            earliest_min=a.earliest_min,
            latest_min=a.latest_min,
        )
        for a in appliances
    ]

    # Baseline
    rate = build_tou_tariff(req.day_minutes)
    base_sched, base_cost, base_peak = baseline_schedule(vars_, req.day_minutes, rate)

    # CSP Optimize
    best_sched, best_cost, best_peak, runtime_ms = optimize_csp(
        vars_,
        day_minutes=req.day_minutes,
        power_limit_w=req.power_limit_w,
        night_usage_allowed=prefs.night_usage_allowed,
        cost_saving_priority=prefs.cost_saving_priority,
        max_delay_min=prefs.max_delay_min,
    )

    run = crud.create_run(
        db,
        algorithm="Backtracking CSP",
        objective="Minimize Cost + Peak Load",
        total_cost=best_cost,
        peak_kw=best_peak,
        runtime_ms=runtime_ms,
        baseline_cost=base_cost,
        baseline_peak_kw=base_peak,
        schedule=best_sched,
    )

    return schemas.OptimizeResponse(
        run_id=run.id,
        algorithm=run.algorithm,
        objective=run.objective,
        total_cost=best_cost,
        peak_kw=best_peak,
        runtime_ms=runtime_ms,
        baseline_cost=base_cost,
        baseline_peak_kw=base_peak,
        schedule=[schemas.ScheduleItem(**it) for it in best_sched],
    )

# ---------- Dashboard / Analytics / History ----------
@app.get("/dashboard", response_model=schemas.DashboardSummary)
def dashboard(db: Session = Depends(get_db)):
    runs = crud.list_runs(db, limit=1)
    if not runs:
        return schemas.DashboardSummary(
            todays_cost=0.0, baseline_cost=0.0, savings_percent=0.0, peak_load_kw=0.0
        )
    r = runs[0]
    savings = 0.0
    if r.baseline_cost > 0:
        savings = max(0.0, (r.baseline_cost - r.total_cost) / r.baseline_cost) * 100.0
    return schemas.DashboardSummary(
        todays_cost=r.total_cost,
        baseline_cost=r.baseline_cost,
        savings_percent=round(savings, 2),
        peak_load_kw=r.peak_kw,
    )

@app.get("/analytics", response_model=schemas.AnalyticsOut)
def analytics(db: Session = Depends(get_db)):
    runs = crud.list_runs(db, limit=7)
    if not runs:
        return schemas.AnalyticsOut(
            cost_baseline=0.0, cost_optimized=0.0, peak_before_kw=0.0, peak_after_kw=0.0,
            weekly_costs=[0,0,0,0,0,0,0]
        )

    latest = runs[0]
    weekly = list(reversed([r.total_cost for r in runs]))
    weekly = ([0.0] * (7 - len(weekly))) + weekly  # pad to 7

    return schemas.AnalyticsOut(
        cost_baseline=latest.baseline_cost,
        cost_optimized=latest.total_cost,
        peak_before_kw=latest.baseline_peak_kw,
        peak_after_kw=latest.peak_kw,
        weekly_costs=weekly,
    )

@app.get("/history", response_model=list[schemas.HistoryItem])
def history(db: Session = Depends(get_db)):
    runs = crud.list_runs(db, limit=30)
    out = []
    for r in runs:
        savings = 0.0
        if r.baseline_cost > 0:
            savings = max(0.0, (r.baseline_cost - r.total_cost) / r.baseline_cost) * 100.0
        out.append(schemas.HistoryItem(
            id=r.id,
            created_at=r.created_at,
            total_cost=r.total_cost,
            peak_kw=r.peak_kw,
            savings_percent=round(savings, 2),
        ))
    return out

@app.get("/runs/{run_id}", response_model=schemas.OptimizeResponse)
def run_details(run_id: int, db: Session = Depends(get_db)):
    r = crud.get_run(db, run_id)
    if not r:
        raise HTTPException(status_code=404, detail="Run not found")
    sched = json.loads(r.schedule_json or "[]")
    return schemas.OptimizeResponse(
        run_id=r.id,
        algorithm=r.algorithm,
        objective=r.objective,
        total_cost=r.total_cost,
        peak_kw=r.peak_kw,
        runtime_ms=r.runtime_ms,
        baseline_cost=r.baseline_cost,
        baseline_peak_kw=r.baseline_peak_kw,
        schedule=[schemas.ScheduleItem(**it) for it in sched],
    )
