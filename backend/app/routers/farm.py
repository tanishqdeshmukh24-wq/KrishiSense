from uuid import UUID

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.database import get_db
from app.models import Farm, Field, User, Zone
from app.routers.auth import get_current_user
from app.schemas.core import (
    FarmCreate,
    FarmResponse,
    FieldCreate,
    FieldResponse,
    ZoneCreate,
    ZoneResponse,
)

router = APIRouter(prefix="/farms", tags=["farms"])


def get_owned_farm(db: Session, current_user: User, farm_id: UUID) -> Farm:
    farm = db.query(Farm).filter(Farm.id == farm_id, Farm.owner_id == current_user.id).first()
    if not farm:
        raise HTTPException(status_code=404, detail="Farm not found")
    return farm


@router.post("", response_model=FarmResponse, status_code=status.HTTP_201_CREATED)
def create_farm(payload: FarmCreate, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    farm = Farm(owner_id=current_user.id, name=payload.name, location=payload.location)
    db.add(farm)
    db.commit()
    db.refresh(farm)
    return farm


@router.get("", response_model=list[FarmResponse])
def list_farms(db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    return db.query(Farm).filter(Farm.owner_id == current_user.id).all()


@router.post("/{farm_id}/fields", response_model=FieldResponse, status_code=status.HTTP_201_CREATED)
def create_field(
    farm_id: UUID,
    payload: FieldCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    get_owned_farm(db, current_user, farm_id)
    if payload.farm_id != farm_id:
        raise HTTPException(status_code=400, detail="farm_id does not match path")
    field = Field(farm_id=farm_id, name=payload.name, area_acres=payload.area_acres)
    db.add(field)
    db.commit()
    db.refresh(field)
    return field


@router.get("/{farm_id}/fields", response_model=list[FieldResponse])
def list_fields(farm_id: UUID, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    get_owned_farm(db, current_user, farm_id)
    return db.query(Field).filter(Field.farm_id == farm_id).all()


@router.post("/{farm_id}/fields/{field_id}/zones", response_model=ZoneResponse, status_code=status.HTTP_201_CREATED)
def create_zone(
    farm_id: UUID,
    field_id: UUID,
    payload: ZoneCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    get_owned_farm(db, current_user, farm_id)
    field = db.query(Field).filter(Field.id == field_id, Field.farm_id == farm_id).first()
    if not field:
        raise HTTPException(status_code=404, detail="Field not found")
    if payload.field_id != field_id:
        raise HTTPException(status_code=400, detail="field_id does not match path")
    zone = Zone(field_id=field_id, name=payload.name, area_acres=payload.area_acres)
    db.add(zone)
    db.commit()
    db.refresh(zone)
    return zone


@router.get("/{farm_id}/fields/{field_id}/zones", response_model=list[ZoneResponse])
def list_zones(
    farm_id: UUID,
    field_id: UUID,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    get_owned_farm(db, current_user, farm_id)
    field = db.query(Field).filter(Field.id == field_id, Field.farm_id == farm_id).first()
    if not field:
        raise HTTPException(status_code=404, detail="Field not found")
    return db.query(Zone).filter(Zone.field_id == field_id).all()
