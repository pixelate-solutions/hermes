import uuid

from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware

from app.api.routes import auth, billing, leads, profile, public, recipes
from app.core.config import get_settings
from app.core.logging import configure_logging, get_logger

configure_logging()
logger = get_logger("api")
settings = get_settings()

app = FastAPI(title="Hermes API", version="0.1.0")
app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        settings.hermes_flutter_web_url,
        "http://localhost:8080",
        "http://localhost:8081",
    ],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.middleware("http")
async def add_request_context(request: Request, call_next):
    request_id = request.headers.get("x-request-id", str(uuid.uuid4()))
    logger.info("request.start", request_id=request_id, path=request.url.path, method=request.method)
    response = await call_next(request)
    response.headers["x-request-id"] = request_id
    logger.info("request.end", request_id=request_id, status_code=response.status_code)
    return response


app.include_router(public.router)
app.include_router(auth.router)
app.include_router(leads.router)
app.include_router(profile.router)
app.include_router(recipes.router)
app.include_router(billing.router)
