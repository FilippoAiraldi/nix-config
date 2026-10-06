"""Request/response models, following the GLiDE `/v1/systemone` contract."""

from __future__ import annotations

from typing import Annotated, Any, Literal, Union

from pydantic import BaseModel, ConfigDict, Field, field_validator

MAX_OPTIONS = 255

State = Union[str, dict[str, Any], list[Any]]


class NoulQuestion(BaseModel):
    type: Literal["noul"]
    instructions: str | None = None
    # Optional {"true": "...", "false": "..."}; defaults to Yes/No.
    criteria: dict[Literal["true", "false"], str] | None = None


class ChoiceQuestion(BaseModel):
    type: Literal["choice"]
    instructions: str | None = None
    # Option key -> description of the option.
    criteria: dict[str, str] = Field(min_length=2, max_length=MAX_OPTIONS)


class ScoreQuestion(BaseModel):
    type: Literal["score"]
    instructions: str | None = None
    # Ordered level descriptions, lowest first.
    criteria: list[str] = Field(min_length=2, max_length=MAX_OPTIONS)


Question = Annotated[
    Union[NoulQuestion, ChoiceQuestion, ScoreQuestion], Field(discriminator="type")
]


class SystemOneRequest(BaseModel):
    # `model` is accepted so GLiDE clients work unchanged, but there is only one
    # model behind this endpoint; the response reports which one answered.
    model_config = ConfigDict(protected_namespaces=())

    model: str | None = None
    state: State
    questions: dict[str, Question] = Field(min_length=1)

    @field_validator("state")
    @classmethod
    def _state_not_empty(cls, value: State) -> State:
        if isinstance(value, str):
            if not value.strip():
                raise ValueError("state must not be empty")
        elif not value:
            raise ValueError("state must not be empty")
        return value


class NoulAnswer(BaseModel):
    type: Literal["noul"] = "noul"
    noul: float
    confidence: float


class ChoiceAnswer(BaseModel):
    type: Literal["choice"] = "choice"
    choice: str
    confidence: float
    probabilities: dict[str, float]


class ScoreAnswer(BaseModel):
    type: Literal["score"] = "score"
    score: int
    expected_level: float
    confidence: float
    probabilities: dict[str, float]
    legend: dict[str, str]


Answer = Union[NoulAnswer, ChoiceAnswer, ScoreAnswer]


class SystemOneResponse(BaseModel):
    model_config = ConfigDict(protected_namespaces=())

    model: str
    answers: dict[str, Answer]
