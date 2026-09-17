from uuid import UUID

from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel, Field
from sqlalchemy.orm import Session

from app.database import get_db
from app.models import Farm, Field, Recommendation, SensorNode, SensorReading, Zone
from app.routers.auth import get_current_user

router = APIRouter(prefix="/decision-engine", tags=["decision-engine"])


class DecisionRequest(BaseModel):
    zone_id: UUID
    soil_moisture: float | None = Field(default=None, ge=0, le=100)
    crop: str | None = None
    growth_stage: str | None = None
    rain_expected: bool | None = None


class DecisionResponse(BaseModel):
    decision: str
    priority: str
    reason: str


def owned_zone(db: Session, user_id: UUID, zone_id: UUID) -> Zone:
    zone = (
        db.query(Zone)
        .join(Field, Zone.field_id == Field.id)
        .join(Farm, Field.farm_id == Farm.id)
        .filter(Zone.id == zone_id, Farm.owner_id == user_id)
        .first()
    )
    if not zone:
        raise HTTPException(status_code=404, detail="Zone not found")
    return zone


@router.post("/evaluate", response_model=DecisionResponse)
def evaluate_decision(
    payload: DecisionRequest,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    zone = owned_zone(db, current_user.id, payload.zone_id)
    moisture = payload.soil_moisture
    if moisture is None:
        latest = (
            db.query(SensorReading)
            .filter(SensorReading.zone_id == zone.id)
            .order_by(SensorReading.timestamp.desc())
            .first()
        )
        moisture = latest.soil_moisture if latest else None

    if moisture is None:
        return DecisionResponse(decision="INSUFFICIENT_DATA", priority="MEDIUM", reason="No soil-moisture reading is available for this zone.")

    # The decision engine owns agronomic logic. This endpoint only defines the stable backend boundary.
    raise HTTPException(status_code=501, detail="Decision engine implementation is owned by Tanishq and is not implemented in the core backend")
