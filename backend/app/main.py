from fastapi import FastAPI, HTTPException, Request
from  fastapi.exceptions import RequestValidationError
from fastapi.responses import JSONResponse

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

@app.exception_handler(HTTPException)
async def http_exception_handler(
    request: Request,
    exc: HTTPException,
):
    status_to_code = {
        400: "BAD_REQUEST",
        401: "UNAUTHORIZED",
        403: "FORBIDDEN",
        404: "NOT_FOUND",
        409: "CONFLICT",
        422: "VALIDATION_ERROR",
        500: "INTERNAL_SERVER_ERROR",
    }

    code = status_to_code.get(
        exc.status_code,
        "HTTP_ERROR",
    )

    return JSONResponse(
        status_code=exc.status_code,
        content={
            "error": {
                "code": code,
                "message": str(exc.detail),
            }
        },
    )


@app.exception_handler(RequestValidationError)
async def validation_exception_handler(
    request: Request,
    exc: RequestValidationError,
):
    return JSONResponse(
        status_code=422,
        content={
            "error": {
                "code": "VALIDATION_ERROR",
                "message": "Invalid request data.",
            }
        },
    )


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
