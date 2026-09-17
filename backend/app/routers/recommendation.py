from uuid import UUID

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.database import get_db
from app.models import Farm, Field, Recommendation, Zone
from app.routers.auth import get_current_user
from app.schemas.core import RecommendationCreate, RecommendationResponse

router = APIRouter(prefix="/recommendations", tags=["recommendations"])


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


@router.post("", response_model=RecommendationResponse, status_code=status.HTTP_201_CREATED)
def create_recommendation(
    payload: RecommendationCreate,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    ensure_owned_zone(db, current_user.id, payload.zone_id)
    recommendation = Recommendation(**payload.model_dump())
    db.add(recommendation)
    db.commit()
    db.refresh(recommendation)
    return recommendation


@router.get("", response_model=list[RecommendationResponse])
def list_recommendations(
    zone_id: UUID | None = None,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    query = (
        db.query(Recommendation)
        .join(Zone, Recommendation.zone_id == Zone.id)
        .join(Field, Zone.field_id == Field.id)
        .join(Farm, Field.farm_id == Farm.id)
        .filter(Farm.owner_id == current_user.id)
    )
    if zone_id is not None:
        ensure_owned_zone(db, current_user.id, zone_id)
        query = query.filter(Recommendation.zone_id == zone_id)
    return query.order_by(Recommendation.created_at.desc()).all()
