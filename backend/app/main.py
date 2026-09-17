from fastapi import FastAPI

from app.config import get_settings
from app.database import Base, engine
from app import models  # noqa: F401
from app.routers.auth import router as auth_router
from app.routers.farm import router as farm_router

settings = get_settings()
app = FastAPI(title=settings.app_name)


@app.on_event("startup")
def create_tables() -> None:
    Base.metadata.create_all(bind=engine)


@app.get("/health")
def health() -> dict[str, str]:
    return {"status": "ok"}


app.include_router(auth_router)
app.include_router(farm_router)
