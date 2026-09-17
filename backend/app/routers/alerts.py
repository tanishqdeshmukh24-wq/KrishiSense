from uuid import UUID

from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel, Field
from sqlalchemy.orm import Session

from app.database import get_db
from app.models import Alert, Farm, Field, Zone
from app.routers.auth import get_current_user

router = APIRouter(prefix="/alerts", tags=["alerts"])


class AlertCreate(BaseModel):
    zone_id: UUID | None = None
    type: str = Field(min_length=1, max_length=50)
    message: str = Field(min_length=1)
    severity: str = Field(default="INFO", min_length=1, max_length=20)


class AlertResponse(BaseModel):
    id: UUID
    zone_id: UUID | None
    type: str
    message: str
    severity: str
    is_read: bool


def ensure_owned_zone(db: Session, user_id: UUID, zone_id: UUID) -> Zone:
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


@router.post("", response_model=AlertResponse, status_code=status.HTTP_201_CREATED)
def create_alert(
    payload: AlertCreate,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    if payload.zone_id is not None:
        ensure_owned_zone(db, current_user.id, payload.zone_id)
    alert = Alert(**payload.model_dump())
    db.add(alert)
    db.commit()
    db.refresh(alert)
    return alert


@router.get("", response_model=list[AlertResponse])
def list_alerts(db: Session = Depends(get_db), current_user=Depends(get_current_user)):
    return (
        db.query(Alert)
        .outerjoin(Zone, Alert.zone_id == Zone.id)
        .outerjoin(Field, Zone.field_id == Field.id)
        .outerjoin(Farm, Field.farm_id == Farm.id)
        .filter((Alert.zone_id.is_(None)) | (Farm.owner_id == current_user.id))
        .order_by(Alert.created_at.desc())
        .all()
    )
