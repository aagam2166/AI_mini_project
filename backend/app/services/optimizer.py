from __future__ import annotations
from dataclasses import dataclass
from typing import List, Dict, Tuple
import time
import math

@dataclass
class ApplianceVar:
    id: int
    name: str
    power_w: int
    duration_min: int
    earliest_min: int
    latest_min: int

def minute_to_kwh(power_w: int, minutes: int) -> float:
    # W -> kW, minutes -> hours
    return (power_w / 1000.0) * (minutes / 60.0)

def build_tou_tariff(day_minutes: int) -> List[float]:
    """
    Simple Time-of-Use tariff per minute (₹/kWh). You can replace with real rates.
    Off-peak night cheaper, evening peak costlier.
    """
    rates = [6.0] * day_minutes
    for m in range(day_minutes):
        hour = m // 60
        if 0 <= hour < 6:
            rates[m] = 3.5
        elif 18 <= hour < 22:
            rates[m] = 8.5
        elif 12 <= hour < 16:
            rates[m] = 6.8
        else:
            rates[m] = 5.5
    return rates

def schedule_cost(power_w: int, start: int, duration: int, rate_per_min: List[float]) -> float:
    # integrate kWh * rate over minutes
    cost = 0.0
    for m in range(start, start + duration):
        r = rate_per_min[m]
        cost += minute_to_kwh(power_w, 1) * r
    return cost

def compute_peak_kw(load_w: List[int]) -> float:
    return (max(load_w) / 1000.0) if load_w else 0.0

def baseline_schedule(vars_: List[ApplianceVar], day_minutes: int, rate: List[float]) -> Tuple[List[Dict], float, float]:
    """
    Baseline: schedule each appliance at earliest possible.
    """
    load = [0] * day_minutes
    schedule = []
    for v in vars_:
        start = max(0, min(v.earliest_min, day_minutes - v.duration_min))
        end = start + v.duration_min
        for m in range(start, end):
            load[m] += v.power_w
        schedule.append({
            "appliance_id": v.id,
            "appliance_name": v.name,
            "start_min": start,
            "end_min": end,
            "power_w": v.power_w,
            "cost": round(schedule_cost(v.power_w, start, v.duration_min, rate), 4),
        })
    total = sum(it["cost"] for it in schedule)
    peak = compute_peak_kw(load)
    return schedule, total, peak

def optimize_csp(
    vars_: List[ApplianceVar],
    *,
    day_minutes: int,
    power_limit_w: int,
    night_usage_allowed: bool,
    cost_saving_priority: float,
    max_delay_min: int,
) -> Tuple[List[Dict], float, float, int]:
    """
    CSP Backtracking with objective (cost + peak penalty).
    Returns: best_schedule, best_cost, best_peak_kw, runtime_ms
    """
    t0 = time.time()
    rate = build_tou_tariff(day_minutes)

    # minute load tracking for constraint checking
    load = [0] * day_minutes

    # domain: 15-min grid
    def domain(v: ApplianceVar) -> List[int]:
        start_lo = max(0, v.earliest_min)
        start_hi = min(v.latest_min, day_minutes - v.duration_min)
        starts = list(range(start_lo, start_hi + 1, 15))
        return starts

    # ordering: higher power + longer duration first (harder vars early)
    vars_sorted = sorted(vars_, key=lambda x: (x.power_w * x.duration_min), reverse=True)

    best = {
        "obj": float("inf"),
        "schedule": None,
        "cost": float("inf"),
        "peak": float("inf"),
    }

    # small helper: apply/remove
    def can_place(v: ApplianceVar, start: int) -> bool:
        end = start + v.duration_min
        if end > day_minutes:
            return False

        # night constraint: forbid scheduling between 22:00-06:00 if not allowed
        if not night_usage_allowed:
            for m in range(start, end):
                hour = m // 60
                if hour >= 22 or hour < 6:
                    return False

        # power limit check
        for m in range(start, end):
            if load[m] + v.power_w > power_limit_w:
                return False
        return True

    def place(v: ApplianceVar, start: int):
        end = start + v.duration_min
        for m in range(start, end):
            load[m] += v.power_w

    def unplace(v: ApplianceVar, start: int):
        end = start + v.duration_min
        for m in range(start, end):
            load[m] -= v.power_w

    def partial_lower_bound_cost(assigned: List[Tuple[ApplianceVar, int]]) -> float:
        # sum of actual scheduled costs so far (optimistic LB)
        c = 0.0
        for v, s in assigned:
            c += schedule_cost(v.power_w, s, v.duration_min, rate)
        return c

    def compute_objective(schedule_items: List[Dict]) -> Tuple[float, float, float]:
        total_cost = sum(it["cost"] for it in schedule_items)
        peak = compute_peak_kw(load)

        # peak penalty scaled by priority (0..1): higher priority => more weight on cost saving,
        # lower priority => more weight on peak reduction
        peak_weight = (1.0 - cost_saving_priority) * 4.0

        # comfort penalty: prefer earlier starts; allow delay up to max_delay_min
        comfort_penalty = 0.0
        for it in schedule_items:
            # delay from earliest, normalized
            # if unknown earliest, keep 0
            comfort_penalty += max(0.0, (it["start_min"] - it.get("earliest_min", it["start_min"])) / max(1, max_delay_min))

        obj = total_cost + peak_weight * peak + 0.2 * comfort_penalty
        return obj, total_cost, peak

    assigned: List[Tuple[ApplianceVar, int]] = []

    def backtrack(i: int):
        # prune
        lb = partial_lower_bound_cost(assigned)
        if lb >= best["obj"]:
            return

        if i == len(vars_sorted):
            # build schedule items
            items = []
            for v, s in assigned:
                cost = schedule_cost(v.power_w, s, v.duration_min, rate)
                items.append({
                    "appliance_id": v.id,
                    "appliance_name": v.name,
                    "start_min": s,
                    "end_min": s + v.duration_min,
                    "power_w": v.power_w,
                    "cost": round(cost, 4),
                    "earliest_min": v.earliest_min,
                })
            obj, total_cost, peak = compute_objective(items)
            if obj < best["obj"]:
                best["obj"] = obj
                best["schedule"] = items
                best["cost"] = total_cost
                best["peak"] = peak
            return

        v = vars_sorted[i]
        starts = domain(v)

        # heuristic: try cheaper start times first
        starts = sorted(starts, key=lambda s: schedule_cost(v.power_w, s, v.duration_min, rate))

        for s in starts:
            if can_place(v, s):
                place(v, s)
                assigned.append((v, s))
                backtrack(i + 1)
                assigned.pop()
                unplace(v, s)

    backtrack(0)

    runtime_ms = int((time.time() - t0) * 1000)

    # if no schedule found, return empty
    if best["schedule"] is None:
        return [], 0.0, 0.0, runtime_ms

    return best["schedule"], float(best["cost"]), float(best["peak"]), runtime_ms
