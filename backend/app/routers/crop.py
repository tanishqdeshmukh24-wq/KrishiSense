from uuid import UUID

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.database import get_db
from app.models import Crop, Farm, Field, Zone
from app.routers.auth import get_current_user
from app.schemas.core import CropCreate, CropResponse

router = APIRouter(prefix="/crops", tags=["crops"])


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


@router.post("", response_model=CropResponse, status_code=status.HTTP_201_CREATED)
def create_crop(
    payload: CropCreate,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    zone = ensure_owned_zone(db, current_user.id, payload.zone_id)
    if db.query(Crop).filter(Crop.zone_id == zone.id).first():
        raise HTTPException(status_code=409, detail="A crop is already associated with this zone")
    crop = Crop(**payload.model_dump())
    db.add(crop)
    db.commit()
    db.refresh(crop)
    return crop


@router.put("/{crop_id}", response_model=CropResponse)
def update_crop(
    crop_id: UUID,
    payload: CropCreate,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    crop = db.query(Crop).filter(Crop.id == crop_id).first()
    if not crop:
        raise HTTPException(status_code=404, detail="Crop not found")
    ensure_owned_zone(db, current_user.id, crop.zone_id)
    ensure_owned_zone(db, current_user.id, payload.zone_id)
    existing = db.query(Crop).filter(Crop.zone_id == payload.zone_id, Crop.id != crop.id).first()
    if existing:
        raise HTTPException(status_code=409, detail="A crop is already associated with this zone")
    crop.name = payload.name
    crop.zone_id = payload.zone_id
    crop.growth_stage = payload.growth_stage
    db.commit()
    db.refresh(crop)
    return crop


@router.get("", response_model=list[CropResponse])
def list_crops(db: Session = Depends(get_db), current_user=Depends(get_current_user)):
    return (
        db.query(Crop)
        .join(Zone, Crop.zone_id == Zone.id)
        .join(Field, Zone.field_id == Field.id)
        .join(Farm, Field.farm_id == Farm.id)
        .filter(Farm.owner_id == current_user.id)
        .all()
    )
