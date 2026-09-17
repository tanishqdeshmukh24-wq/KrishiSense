from datetime import datetime, timezone
from uuid import UUID

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.config import get_settings
from app.database import get_db
from app.models import Field, Farm, SensorNode, SensorReading, User, Zone
from app.routers.auth import get_current_user
from app.schemas.core import NodeCreate, NodeResponse, SensorReadingCreate, SensorReadingResponse

router = APIRouter(tags=["sensors"])
settings = get_settings()


def ensure_owned_zone(db: Session, current_user: User, zone_id: UUID) -> Zone:
    zone = (
        db.query(Zone)
        .join(Field, Zone.field_id == Field.id)
        .join(Farm, Field.farm_id == Farm.id)
        .filter(Zone.id == zone_id, Farm.owner_id == current_user.id)
        .first()
    )
    if not zone:
        raise HTTPException(status_code=404, detail="Zone not found")
    return zone


@router.post("/nodes", response_model=NodeResponse, status_code=status.HTTP_201_CREATED)
def create_node(
    payload: NodeCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    farm = db.query(Farm).filter(Farm.id == payload.farm_id, Farm.owner_id == current_user.id).first()
    if not farm:
        raise HTTPException(status_code=404, detail="Farm not found")

    field = db.query(Field).filter(Field.id == payload.field_id, Field.farm_id == farm.id).first()
    if not field:
        raise HTTPException(status_code=404, detail="Field not found")

    zone = db.query(Zone).filter(Zone.id == payload.zone_id, Zone.field_id == field.id).first()
    if not zone:
        raise HTTPException(status_code=404, detail="Zone not found")

    if db.query(SensorNode).filter(SensorNode.node_id == payload.node_id).first():
        raise HTTPException(status_code=409, detail="node_id already registered")
    if db.query(SensorNode).filter(SensorNode.device_id == payload.device_id).first():
        raise HTTPException(status_code=409, detail="device_id already registered")

    node = SensorNode(
        node_id=payload.node_id,
        device_id=payload.device_id,
        farm_id=farm.id,
        field_id=field.id,
        zone_id=zone.id,
        status="OFFLINE",
    )
    db.add(node)
    db.commit()
    db.refresh(node)
    return node


@router.get("/nodes", response_model=list[NodeResponse])
def list_nodes(db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    return db.query(SensorNode).join(Farm, SensorNode.farm_id == Farm.id).filter(Farm.owner_id == current_user.id).all()


@router.get("/nodes/{node_id}", response_model=NodeResponse)
def get_node(node_id: str, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    node = (
        db.query(SensorNode)
        .join(Farm, SensorNode.farm_id == Farm.id)
        .filter(SensorNode.node_id == node_id, Farm.owner_id == current_user.id)
        .first()
    )
    if not node:
        raise HTTPException(status_code=404, detail="Node not found")
    update_node_status(node)
    db.commit()
    db.refresh(node)
    return node


@router.post("/sensor/readings", response_model=SensorReadingResponse, status_code=status.HTTP_201_CREATED)
def create_sensor_reading(payload: SensorReadingCreate, db: Session = Depends(get_db)):
    node = db.query(SensorNode).filter(SensorNode.node_id == payload.node_id).first()
    if not node:
        raise HTTPException(status_code=404, detail="Node not found")
    if node.zone_id != payload.zone_id:
        raise HTTPException(status_code=400, detail="Node does not belong to the supplied zone")
    if payload.timestamp.tzinfo is not None:
        timestamp = payload.timestamp.astimezone(timezone.utc).replace(tzinfo=None)
    else:
        timestamp = payload.timestamp

    reading = SensorReading(
        node_id=node.id,
        zone_id=node.zone_id,
        soil_moisture=payload.soil_moisture,
        timestamp=timestamp,
    )
    node.last_seen = datetime.utcnow()
    node.status = "ONLINE"
    db.add(reading)
    db.commit()
    db.refresh(reading)
    return reading


@router.get("/sensor/readings/{node_id}", response_model=list[SensorReadingResponse])
def sensor_history(node_id: str, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    node = (
        db.query(SensorNode)
        .join(Farm, SensorNode.farm_id == Farm.id)
        .filter(SensorNode.node_id == node_id, Farm.owner_id == current_user.id)
        .first()
    )
    if not node:
        raise HTTPException(status_code=404, detail="Node not found")
    return db.query(SensorReading).filter(SensorReading.node_id == node.id).order_by(SensorReading.timestamp.desc()).all()


def update_node_status(node: SensorNode) -> None:
    if node.last_seen is None:
        node.status = "OFFLINE"
        return
    elapsed = (datetime.utcnow() - node.last_seen).total_seconds()
    node.status = "ONLINE" if elapsed <= settings.node_offline_timeout_seconds else "OFFLINE"
