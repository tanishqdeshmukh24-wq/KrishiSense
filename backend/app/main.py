from fastapi import FastAPI

from app.config import get_settings
from app.database import Base, engine
from app import models  # noqa: F401
from app.routers.ai import router as ai_router
from app.routers.alerts import router as alerts_router
from app.routers.auth import router as auth_router
from app.routers.crop import router as crop_router
from app.routers.decision import router as decision_router
from app.routers.farm import router as farm_router
from app.routers.recommendation import router as recommendation_router
from app.routers.sensor import router as sensor_router

settings = get_settings()
app = FastAPI(title=settings.app_name)


@app.on_event("startup")
def create_tables() -> None:
    Base.metadata.create_all(bind=engine)


@app.get("/health")
def health() -> dict[str, str]:
    return {"status": "ok"}


app.include_router(auth_router)
app.include_router(ai_router)
app.include_router(alerts_router)
app.include_router(crop_router)
app.include_router(decision_router)
app.include_router(farm_router)
app.include_router(sensor_router)
app.include_router(recommendation_router)
