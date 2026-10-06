"""FastAPI app. The model is loaded once at startup and kept in memory."""

from __future__ import annotations

import logging
import os
import threading
from contextlib import asynccontextmanager
from typing import Any

from fastapi import FastAPI, HTTPException, Request
from fastapi.concurrency import run_in_threadpool
from gliner2.classification import SchemaError

from .engine import decide
from .schemas import SystemOneRequest, SystemOneResponse

MODEL_ID = os.environ.get("DECISIONS_MODEL", "fastino/GLiNER2.5-Decide")

log = logging.getLogger("decisions")


def load_classifier() -> Any:
    from gliner2.classification import Classifier

    log.info("loading %s", MODEL_ID)
    classifier = Classifier.from_pretrained(MODEL_ID)
    log.info("model ready")
    return classifier


@asynccontextmanager
async def lifespan(app: FastAPI):
    # Tests can pre-set `app.state.classifier` to skip loading the real model.
    if getattr(app.state, "classifier", None) is None:
        app.state.classifier = load_classifier()
    app.state.lock = threading.Lock()
    yield


app = FastAPI(title="decisions", lifespan=lifespan)


@app.get("/health")
async def health(request: Request) -> dict[str, str]:
    ready = getattr(request.app.state, "classifier", None) is not None
    if not ready:
        raise HTTPException(status_code=503, detail="model not loaded")
    return {"status": "ok", "model": MODEL_ID}


@app.post("/v1/systemone", response_model_exclude_none=True)
async def systemone(body: SystemOneRequest, request: Request) -> SystemOneResponse:
    state = request.app.state

    def run():
        # One model instance: serialize inference instead of racing on it.
        with state.lock:
            return decide(state.classifier, body.state, body.questions)

    try:
        answers = await run_in_threadpool(run)
    except SchemaError as exc:
        raise HTTPException(status_code=422, detail=str(exc)) from exc
    return SystemOneResponse(model=MODEL_ID, answers=answers)
