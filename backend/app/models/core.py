from datetime import datetime
from uuid import UUID, uuid4

from sqlalchemy import Boolean, DateTime, Float, ForeignKey, Integer, String, Text
from sqlalchemy.dialects.sqlite import JSON
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.database import Base


class User(Base):
    __tablename__ = "users"

    id: Mapped[UUID] = mapped_column(primary_key=True, default=uuid4)
    name: Mapped[str] = mapped_column(String(120))
    email: Mapped[str] = mapped_column(String(255), unique=True, index=True)
    password_hash: Mapped[str] = mapped_column(String(255))
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)

    farms: Mapped[list["Farm"]] = relationship(back_populates="owner", cascade="all, delete-orphan")


class Farm(Base):
    __tablename__ = "farms"

    id: Mapped[UUID] = mapped_column(primary_key=True, default=uuid4)
    owner_id: Mapped[UUID] = mapped_column(ForeignKey("users.id", ondelete="CASCADE"), index=True)
    name: Mapped[str] = mapped_column(String(120))
    location: Mapped[str | None] = mapped_column(String(255), nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)

    owner: Mapped[User] = relationship(back_populates="farms")
    fields: Mapped[list["Field"]] = relationship(back_populates="farm", cascade="all, delete-orphan")
    nodes: Mapped[list["SensorNode"]] = relationship(back_populates="farm")


class Field(Base):
    __tablename__ = "fields"

    id: Mapped[UUID] = mapped_column(primary_key=True, default=uuid4)
    farm_id: Mapped[UUID] = mapped_column(ForeignKey("farms.id", ondelete="CASCADE"), index=True)
    name: Mapped[str] = mapped_column(String(120))
    area_acres: Mapped[float | None] = mapped_column(Float, nullable=True)

    farm: Mapped[Farm] = relationship(back_populates="fields")
    zones: Mapped[list["Zone"]] = relationship(back_populates="field", cascade="all, delete-orphan")
    nodes: Mapped[list["SensorNode"]] = relationship(back_populates="field")


class Zone(Base):
    __tablename__ = "zones"

    id: Mapped[UUID] = mapped_column(primary_key=True, default=uuid4)
    field_id: Mapped[UUID] = mapped_column(ForeignKey("fields.id", ondelete="CASCADE"), index=True)
    name: Mapped[str] = mapped_column(String(120))
    area_acres: Mapped[float | None] = mapped_column(Float, nullable=True)

    field: Mapped[Field] = relationship(back_populates="zones")
    crop: Mapped["Crop | None"] = relationship(back_populates="zone", uselist=False, cascade="all, delete-orphan")
    nodes: Mapped[list["SensorNode"]] = relationship(back_populates="zone")
    recommendations: Mapped[list["Recommendation"]] = relationship(back_populates="zone")
    alerts: Mapped[list["Alert"]] = relationship(back_populates="zone")
    irrigation_commands: Mapped[list["IrrigationCommand"]] = relationship(back_populates="zone")


class Crop(Base):
    __tablename__ = "crops"

    id: Mapped[UUID] = mapped_column(primary_key=True, default=uuid4)
    zone_id: Mapped[UUID] = mapped_column(ForeignKey("zones.id", ondelete="CASCADE"), unique=True, index=True)
    name: Mapped[str] = mapped_column(String(120))
    growth_stage: Mapped[str | None] = mapped_column(String(120), nullable=True)

    zone: Mapped[Zone] = relationship(back_populates="crop")


class SensorNode(Base):
    __tablename__ = "sensor_nodes"

    id: Mapped[UUID] = mapped_column(primary_key=True, default=uuid4)
    node_id: Mapped[str] = mapped_column(String(64), unique=True, index=True)
    device_id: Mapped[str] = mapped_column(String(120), unique=True, index=True)
    farm_id: Mapped[UUID] = mapped_column(ForeignKey("farms.id", ondelete="CASCADE"), index=True)
    field_id: Mapped[UUID] = mapped_column(ForeignKey("fields.id", ondelete="CASCADE"), index=True)
    zone_id: Mapped[UUID] = mapped_column(ForeignKey("zones.id", ondelete="CASCADE"), index=True)
    status: Mapped[str] = mapped_column(String(20), default="OFFLINE")
    last_seen: Mapped[datetime | None] = mapped_column(DateTime, nullable=True)

    farm: Mapped[Farm] = relationship(back_populates="nodes")
    field: Mapped[Field] = relationship(back_populates="nodes")
    zone: Mapped[Zone] = relationship(back_populates="nodes")
    readings: Mapped[list["SensorReading"]] = relationship(back_populates="node", cascade="all, delete-orphan")


class SensorReading(Base):
    __tablename__ = "sensor_readings"

    id: Mapped[UUID] = mapped_column(primary_key=True, default=uuid4)
    node_id: Mapped[UUID] = mapped_column(ForeignKey("sensor_nodes.id", ondelete="CASCADE"), index=True)
    zone_id: Mapped[UUID] = mapped_column(ForeignKey("zones.id", ondelete="CASCADE"), index=True)
    soil_moisture: Mapped[float] = mapped_column(Float)
    timestamp: Mapped[datetime] = mapped_column(DateTime, index=True)

    node: Mapped[SensorNode] = relationship(back_populates="readings")


class AIAnalysis(Base):
    __tablename__ = "ai_analyses"

    id: Mapped[UUID] = mapped_column(primary_key=True, default=uuid4)
    zone_id: Mapped[UUID | None] = mapped_column(ForeignKey("zones.id", ondelete="SET NULL"), nullable=True, index=True)
    prediction: Mapped[str] = mapped_column(String(255))
    confidence: Mapped[float] = mapped_column(Float)
    explanation: Mapped[str | None] = mapped_column(Text, nullable=True)
    recommendation: Mapped[str | None] = mapped_column(Text, nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)


class Recommendation(Base):
    __tablename__ = "recommendations"

    id: Mapped[UUID] = mapped_column(primary_key=True, default=uuid4)
    zone_id: Mapped[UUID] = mapped_column(ForeignKey("zones.id", ondelete="CASCADE"), index=True)
    type: Mapped[str] = mapped_column(String(50))
    priority: Mapped[str] = mapped_column(String(20))
    message: Mapped[str] = mapped_column(Text)
    source: Mapped[str] = mapped_column(String(50))
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)

    zone: Mapped[Zone] = relationship(back_populates="recommendations")


class Alert(Base):
    __tablename__ = "alerts"

    id: Mapped[UUID] = mapped_column(primary_key=True, default=uuid4)
    zone_id: Mapped[UUID | None] = mapped_column(ForeignKey("zones.id", ondelete="CASCADE"), nullable=True, index=True)
    type: Mapped[str] = mapped_column(String(50))
    message: Mapped[str] = mapped_column(Text)
    severity: Mapped[str] = mapped_column(String(20), default="INFO")
    is_read: Mapped[bool] = mapped_column(Boolean, default=False)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)

    zone: Mapped[Zone | None] = relationship(back_populates="alerts")


class IrrigationCommand(Base):
    __tablename__ = "irrigation_commands"

    id: Mapped[UUID] = mapped_column(primary_key=True, default=uuid4)
    zone_id: Mapped[UUID] = mapped_column(ForeignKey("zones.id", ondelete="CASCADE"), index=True)
    command: Mapped[str] = mapped_column(String(30))
    status: Mapped[str] = mapped_column(String(30), default="PENDING")
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)

    zone: Mapped[Zone] = relationship(back_populates="irrigation_commands")
