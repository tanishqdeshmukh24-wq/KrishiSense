from datetime import datetime
from uuid import UUID

from pydantic import BaseModel, ConfigDict, EmailStr, Field


class UserCreate(BaseModel):
    name: str = Field(min_length=1, max_length=120)
    email: EmailStr
    password: str = Field(min_length=8, max_length=128)


class UserResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: UUID
    name: str
    email: EmailStr
    created_at: datetime


class FarmCreate(BaseModel):
    name: str = Field(min_length=1, max_length=120)
    location: str | None = Field(default=None, max_length=255)


class FarmResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: UUID
    name: str
    location: str | None
    created_at: datetime


class FieldCreate(BaseModel):
    farm_id: UUID
    name: str = Field(min_length=1, max_length=120)
    area_acres: float | None = Field(default=None, gt=0)


class FieldResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: UUID
    farm_id: UUID
    name: str
    area_acres: float | None


class ZoneCreate(BaseModel):
    field_id: UUID
    name: str = Field(min_length=1, max_length=120)
    area_acres: float | None = Field(default=None, gt=0)


class ZoneResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: UUID
    field_id: UUID
    name: str
    area_acres: float | None


class CropCreate(BaseModel):
    zone_id: UUID
    name: str = Field(min_length=1, max_length=120)
    growth_stage: str | None = Field(default=None, max_length=120)


class CropResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: UUID
    zone_id: UUID
    name: str
    growth_stage: str | None


class NodeCreate(BaseModel):
    node_id: str = Field(min_length=1, max_length=64)
    device_id: str = Field(min_length=1, max_length=120)
    farm_id: UUID
    field_id: UUID
    zone_id: UUID


class NodeResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: UUID
    node_id: str
    device_id: str
    farm_id: UUID
    field_id: UUID
    zone_id: UUID
    status: str
    last_seen: datetime | None


class SensorReadingCreate(BaseModel):
    node_id: str = Field(min_length=1, max_length=64)
    zone_id: UUID
    soil_moisture: float = Field(ge=0, le=100)
    timestamp: datetime


class SensorReadingResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: UUID
    node_id: str
    zone_id: UUID
    soil_moisture: float
    timestamp: datetime


class AIAnalysisCreate(BaseModel):
    zone_id: UUID | None = None
    prediction: str = Field(min_length=1, max_length=255)
    confidence: float = Field(ge=0, le=1)
    explanation: str | None = None
    recommendation: str | None = None


class AIAnalysisResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: UUID
    zone_id: UUID | None
    prediction: str
    confidence: float
    explanation: str | None
    recommendation: str | None
    created_at: datetime


class RecommendationCreate(BaseModel):
    zone_id: UUID
    type: str = Field(min_length=1, max_length=50)
    priority: str = Field(min_length=1, max_length=20)
    message: str = Field(min_length=1)
    source: str = Field(min_length=1, max_length=50)


class RecommendationResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: UUID
    zone_id: UUID
    type: str
    priority: str
    message: str
    source: str
    created_at: datetime
