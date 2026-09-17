from uuid import UUID

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.database import get_db
from app.models import AIAnalysis, Farm, Field, Zone
from app.routers.auth import get_current_user
from app.schemas.core import AIAnalysisCreate, AIAnalysisResponse

router = APIRouter(prefix="/ai", tags=["ai"])


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


@router.post("/results", response_model=AIAnalysisResponse, status_code=status.HTTP_201_CREATED)
def store_ai_result(
    payload: AIAnalysisCreate,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    if payload.zone_id is not None:
        ensure_owned_zone(db, current_user.id, payload.zone_id)

    result = AIAnalysis(**payload.model_dump())
    db.add(result)
    db.commit()
    db.refresh(result)
    return result


@router.get("/results", response_model=list[AIAnalysisResponse])
def list_ai_results(
    zone_id: UUID | None = None,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    query = (
        db.query(AIAnalysis)
        .outerjoin(Zone, AIAnalysis.zone_id == Zone.id)
        .outerjoin(Field, Zone.field_id == Field.id)
        .outerjoin(Farm, Field.farm_id == Farm.id)
        .filter((AIAnalysis.zone_id.is_(None)) | (Farm.owner_id == current_user.id))
    )
    if zone_id is not None:
        ensure_owned_zone(db, current_user.id, zone_id)
        query = query.filter(AIAnalysis.zone_id == zone_id)
    return query.order_by(AIAnalysis.created_at.desc()).all()
