from pydantic import BaseModel, Field
from typing import List, Optional
from datetime import datetime

# ---------- Appliance ----------
class ApplianceCreate(BaseModel):
    name: str
    power_w: int
    duration_min: int
    earliest_min: int = 0
    latest_min: int = 1439
    enabled: bool = True

class ApplianceUpdate(BaseModel):
    name: Optional[str] = None
    power_w: Optional[int] = None
    duration_min: Optional[int] = None
    earliest_min: Optional[int] = None
    latest_min: Optional[int] = None
    enabled: Optional[bool] = None

class ApplianceOut(BaseModel):
    id: int
    name: str
    power_w: int
    duration_min: int
    earliest_min: int
    latest_min: int
    enabled: bool

    class Config:
        from_attributes = True

# ---------- Preferences ----------
class PreferencesIn(BaseModel):
    comfort_level: float = Field(ge=0, le=1, default=0.6)
    max_delay_min: int = Field(ge=0, le=600, default=60)
    night_usage_allowed: bool = True
    cost_saving_priority: float = Field(ge=0, le=1, default=0.6)

class PreferencesOut(PreferencesIn):
    id: int
    class Config:
        from_attributes = True

# ---------- Optimization ----------
class ScheduleItem(BaseModel):
    appliance_id: int
    appliance_name: str
    start_min: int
    end_min: int
    power_w: int
    cost: float

class OptimizeRequest(BaseModel):
    power_limit_w: int = 4200
    day_minutes: int = 1440

class OptimizeResponse(BaseModel):
    run_id: int
    algorithm: str
    objective: str
    total_cost: float
    peak_kw: float
    runtime_ms: int
    baseline_cost: float
    baseline_peak_kw: float
    schedule: List[ScheduleItem]

# ---------- Dashboard / Analytics ----------
class DashboardSummary(BaseModel):
    todays_cost: float
    baseline_cost: float
    savings_percent: float
    peak_load_kw: float

class AnalyticsOut(BaseModel):
    cost_baseline: float
    cost_optimized: float
    peak_before_kw: float
    peak_after_kw: float
    weekly_costs: List[float]  # 7 values

class HistoryItem(BaseModel):
    id: int
    created_at: datetime
    total_cost: float
    peak_kw: float
    savings_percent: float

    class Config:
        from_attributes = True
