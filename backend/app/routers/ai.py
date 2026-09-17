from uuid import UUID

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.database import get_db
from app.models import AIAnalysis, Zone
from app.routers.auth import get_current_user
from app.schemas.core import AIAnalysisCreate, AIAnalysisResponse

router = APIRouter(prefix="/ai", tags=["ai"])


@router.post("/results", response_model=AIAnalysisResponse, status_code=status.HTTP_201_CREATED)
def store_ai_result(
    payload: AIAnalysisCreate,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    if payload.zone_id is not None:
        # Ownership is validated through the farm hierarchy in a later shared query.
        zone = (
            db.query(Zone)
            .join(Zone.field)
            .join(Zone.field.farm)
            .filter(Zone.id == payload.zone_id, Zone.field.has(Zone.field.property.mapper.class_.farm.has(owner_id=current_user.id)))
            .first()
        )
        # The nested SQLAlchemy expression above is intentionally not relied on for portability;
        # fall back to a direct ownership traversal.
        if not zone:
            zone = db.query(Zone).filter(Zone.id == payload.zone_id).first()
            if not zone or zone.field.farm.owner_id != current_user.id:
                raise HTTPException(status_code=404, detail="Zone not found")

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
    query = db.query(AIAnalysis)
    if zone_id is not None:
        query = query.join(Zone, AIAnalysis.zone_id == Zone.id).join(Zone.field).join(Zone.field.farm).filter(Zone.id == zone_id, Zone.field.farm.has(owner_id=current_user.id))
    else:
        query = query.outerjoin(Zone, AIAnalysis.zone_id == Zone.id).outerjoin(Zone.field).outerjoin(Zone.field.farm).filter((Zone.id.is_(None)) | (Zone.field.farm.has(owner_id=current_user.id)))
    return query.order_by(AIAnalysis.created_at.desc()).all()
