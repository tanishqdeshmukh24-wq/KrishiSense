from fastapi import FastAPI

from app.config import get_settings
from app.database import Base, engine
from app import models  # noqa: F401

settings = get_settings()
app = FastAPI(title=settings.app_name)


@app.on_event("startup")
def create_tables() -> None:
    Base.metadata.create_all(bind=engine)


@app.get("/health")
def health() -> dict[str, str]:
    return {"status": "ok"}
