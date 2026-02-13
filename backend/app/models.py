from sqlalchemy import Column, Integer, String, Float, Boolean, DateTime, ForeignKey, Text
from sqlalchemy.orm import relationship
from datetime import datetime
from .db import Base

class Appliance(Base):
    __tablename__ = "appliances"
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, nullable=False)
    power_w = Column(Integer, nullable=False)         # e.g. 1500
    duration_min = Column(Integer, nullable=False)    # e.g. 120
    earliest_min = Column(Integer, nullable=False)    # minutes from day start (0..1439)
    latest_min = Column(Integer, nullable=False)      # latest start minute
    enabled = Column(Boolean, default=True)

class Preferences(Base):
    __tablename__ = "preferences"
    id = Column(Integer, primary_key=True, index=True)  # keep single row id=1
    comfort_level = Column(Float, default=0.6)          # 0..1
    max_delay_min = Column(Integer, default=60)         # delay allowed in minutes
    night_usage_allowed = Column(Boolean, default=True)
    cost_saving_priority = Column(Float, default=0.6)   # 0..1

class OptimizationRun(Base):
    __tablename__ = "optimization_runs"
    id = Column(Integer, primary_key=True, index=True)
    created_at = Column(DateTime, default=datetime.utcnow)

    algorithm = Column(String, default="Backtracking CSP")
    objective = Column(String, default="Minimize Cost + Peak Load")

    total_cost = Column(Float, default=0.0)
    peak_kw = Column(Float, default=0.0)
    runtime_ms = Column(Integer, default=0)

    baseline_cost = Column(Float, default=0.0)
    baseline_peak_kw = Column(Float, default=0.0)

    schedule_json = Column(Text, default="[]")  # store as JSON string
