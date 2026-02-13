from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import List, Optional
from csp_solver import solve_csp, calculate_cost, calculate_par, greedy_schedule

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "http://localhost:5173",
        "http://127.0.0.1:5173"
    ],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

class Appliance(BaseModel):
    name: str
    power: float
    duration: int
    earliest: int
    latest: int

class OptimizeRequest(BaseModel):
    appliances: List[Appliance]
    prices: List[float]
    max_par: Optional[float] = None


@app.get("/")
def home():
    return {"message": "Smart Home Energy Backend Running"}


@app.post("/optimize")
def optimize(data: OptimizeRequest):

    class SimpleAppliance:
        def __init__(self, name, power, duration, earliest, latest):
            self.name = name
            self.power = power
            self.duration = duration
            self.earliest = earliest
            self.latest = latest

    appliances = [
        SimpleAppliance(a.name, a.power, a.duration, a.earliest, a.latest)
        for a in data.appliances
    ]

    prices = data.prices

    best_schedule = solve_csp(
        appliances,
        prices,
        max_par=data.max_par
    )

    if best_schedule is None:
        return {
            "optimized": {"schedule": {}, "cost": 0, "par": 0},
            "greedy": {"schedule": {}, "cost": 0, "par": 0},
            "hourly_load": [0]*24,
            "prices": prices,
            "error": "No valid schedule found"
        }

    cost = calculate_cost(best_schedule, appliances, prices)
    par = calculate_par(best_schedule, appliances)

    greedy_sched = greedy_schedule(appliances, prices)
    greedy_cost = calculate_cost(greedy_sched, appliances, prices)
    greedy_par = calculate_par(greedy_sched, appliances)

    hourly_load = [0] * 24
    for appliance in appliances:
        start = best_schedule[appliance.name]
        for h in range(start, start + appliance.duration):
            hourly_load[h] += appliance.power

    return {
        "optimized": {
            "schedule": best_schedule,
            "cost": cost,
            "par": par
        },
        "greedy": {
            "schedule": greedy_sched,
            "cost": greedy_cost,
            "par": greedy_par
        },
        "hourly_load": hourly_load,
        "prices": prices
    }