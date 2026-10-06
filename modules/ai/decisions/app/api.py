"""FastAPI app. The model is loaded once at startup and kept in memory."""

import logging
import os
import threading
import time
from collections.abc import AsyncGenerator
from contextlib import asynccontextmanager

from fastapi import FastAPI, HTTPException, Request
from fastapi.concurrency import run_in_threadpool
from gliner2.classification import SchemaError

from .engine import decide
from .schemas import Answer, SystemOneRequest, SystemOneResponse

MODEL_ID = os.environ.get("AI_DECISIONS_MODEL", "fastino/GLiNER2.5-Decide")
logger = logging.getLogger("uvicorn.error")


@asynccontextmanager
async def lifespan(app: FastAPI) -> AsyncGenerator[None]:
    """Creates shared state at startup.

    Code before `yield` runs once when the server starts; code after it would run at shutdown.
    """
    if getattr(app.state, "classifier", None) is None:
        from gliner2.classification import Classifier

        logger.info("loading %s", MODEL_ID)
        start = time.perf_counter()
        app.state.classifier = Classifier.from_pretrained(MODEL_ID)
        logger.info("model ready after %.1fs", time.perf_counter() - start)

    app.state.lock = threading.Lock()
    yield


app = FastAPI(title="ai.decisions", lifespan=lifespan)


@app.get("/health")
async def health(request: Request) -> dict[str, str]:
    """Reports whether the model is loaded.

    Returns the model id with status "ok", or 503 if the classifier isn't in memory yet.
    """
    if getattr(request.app.state, "classifier", None) is None:
        logger.warning("health check failed: model not loaded")
        raise HTTPException(status_code=503, detail="model not loaded")

    logger.debug("health check ok")
    return {"status": "ok", "model": MODEL_ID}


@app.post("/v1/systemone", response_model_exclude_none=True)
async def systemone(body: SystemOneRequest, request: Request) -> SystemOneResponse:
    """Answers yes/no, pick-one and score questions about a piece of state.

    All questions in the request are scored in a single model pass. Text the model prompt can't
    carry (such as parentheses) is rejected with 422.
    """
    state = request.app.state
    questions = body.questions
    logger.info("SYSTEMONE: %d question(s): %s", len(questions), ", ".join(questions))

    def run() -> dict[str, Answer]:
        """Run inference on a worker thread, one request at a time."""
        with state.lock:
            return decide(state.classifier, body.state, questions)

    start = time.perf_counter()
    try:
        answers = await run_in_threadpool(run)
    except SchemaError as exc:
        logger.warning("SYSTEMONE: rejected with 422: %s", exc)
        raise HTTPException(status_code=422, detail=str(exc)) from exc

    logger.info("SYSTEMONE: answered in %.2fs", time.perf_counter() - start)
    return SystemOneResponse(model=MODEL_ID, answers=answers)

