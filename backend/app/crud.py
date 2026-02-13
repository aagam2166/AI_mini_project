from sqlalchemy.orm import Session
from sqlalchemy import desc
from . import models
from .schemas import ApplianceCreate, ApplianceUpdate, PreferencesIn
from datetime import datetime
import json

# ---------- Appliances ----------
def create_appliance(db: Session, data: ApplianceCreate):
    a = models.Appliance(**data.model_dump())
    db.add(a)
    db.commit()
    db.refresh(a)
    return a

def list_appliances(db: Session):
    return db.query(models.Appliance).order_by(models.Appliance.id).all()

def get_appliance(db: Session, appliance_id: int):
    return db.query(models.Appliance).filter(models.Appliance.id == appliance_id).first()

def update_appliance(db: Session, appliance_id: int, data: ApplianceUpdate):
    a = get_appliance(db, appliance_id)
    if not a:
        return None
    for k, v in data.model_dump(exclude_none=True).items():
        setattr(a, k, v)
    db.commit()
    db.refresh(a)
    return a

def delete_appliance(db: Session, appliance_id: int):
    a = get_appliance(db, appliance_id)
    if not a:
        return False
    db.delete(a)
    db.commit()
    return True

# ---------- Preferences (single row) ----------
def ensure_preferences(db: Session):
    p = db.query(models.Preferences).filter(models.Preferences.id == 1).first()
    if not p:
        p = models.Preferences(id=1)
        db.add(p)
        db.commit()
        db.refresh(p)
    return p

def get_preferences(db: Session):
    return ensure_preferences(db)

def update_preferences(db: Session, data: PreferencesIn):
    p = ensure_preferences(db)
    for k, v in data.model_dump().items():
        setattr(p, k, v)
    db.commit()
    db.refresh(p)
    return p

# ---------- Optimization runs ----------
def create_run(db: Session, *, algorithm: str, objective: str,
               total_cost: float, peak_kw: float, runtime_ms: int,
               baseline_cost: float, baseline_peak_kw: float,
               schedule: list[dict]):
    r = models.OptimizationRun(
        algorithm=algorithm,
        objective=objective,
        total_cost=total_cost,
        peak_kw=peak_kw,
        runtime_ms=runtime_ms,
        baseline_cost=baseline_cost,
        baseline_peak_kw=baseline_peak_kw,
        schedule_json=json.dumps(schedule),
    )
    db.add(r)
    db.commit()
    db.refresh(r)
    return r

def list_runs(db: Session, limit: int = 30):
    return db.query(models.OptimizationRun).order_by(desc(models.OptimizationRun.created_at)).limit(limit).all()

def get_run(db: Session, run_id: int):
    return db.query(models.OptimizationRun).filter(models.OptimizationRun.id == run_id).first()
