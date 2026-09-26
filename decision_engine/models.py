from dataclasses import dataclass
from typing import Optional


@dataclass
class DecisionInput:
    soil_moisture: Optional[float] = None
    crop: Optional[str] = None
    growth_stage: Optional[str] = None
    temperature: Optional[float] = None
    humidity: Optional[float] = None
    rainfall: Optional[float] = None


@dataclass
class DecisionResult:
    decision: str
    priority: str
    reason: str
