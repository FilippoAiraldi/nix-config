"""Request/response models, following the GLiDE `/v1/systemone` contract."""

from typing import Annotated, Any, Literal

from pydantic import BaseModel, ConfigDict, Field, field_validator

MAX_OPTIONS = 255


class NoulQuestion(BaseModel):
    """A yes/no question.

    The answer is a single probability that the statement is true. `criteria` can rename the two
    outcomes (for example "Qualifies" / "Does not qualify"); anything left out falls back to
    "Yes" / "No".
    """

    type: Literal["noul"]
    instructions: str | None = None
    criteria: dict[Literal["true", "false"], str] | None = None


class ChoiceQuestion(BaseModel):
    """A pick-one question.

    `criteria` maps each option key (what the answer returns) to a description of that option (what
    the model reads). At least 2 options are required.
    """

    type: Literal["choice"]
    instructions: str | None = None
    criteria: dict[str, str] = Field(min_length=2, max_length=MAX_OPTIONS)


class ScoreQuestion(BaseModel):
    """A rate-on-a-scale question.

    `criteria` is an ordered list of level descriptions, lowest first. The answer reports the
    position (0-based) of the most likely level.
    """

    type: Literal["score"]
    instructions: str | None = None
    criteria: list[str] = Field(min_length=2, max_length=MAX_OPTIONS)


Question = Annotated[NoulQuestion | ChoiceQuestion | ScoreQuestion, Field(discriminator="type")]
State = str | dict[str, Any] | list[Any]


class SystemOneRequest(BaseModel):
    """Body of `POST /v1/systemone`, i.e., some state plus named questions about it.

    `state` is the thing being judged (free text, or structured data that gets flattened to text).
    `questions` maps a name you choose to a question definition; the response uses the same names as
    keys.
    """

    model_config = ConfigDict(protected_namespaces=())
    model: str | None = None
    state: State
    questions: dict[str, Question] = Field(min_length=1)

    @field_validator("state")
    @classmethod
    def _state_not_empty(cls, value: State) -> State:
        """Reject empty or whitespace-only states."""
        if isinstance(value, str):
            if not value.strip():
                raise ValueError("state must not be empty")
        elif not value:
            raise ValueError("state must not be empty")
        return value


class NoulAnswer(BaseModel):
    """Answer to a `noul` question.

    `noul` is the probability (0 to 1) that the answer is true. `confidence` is 0 at a 50/50 split
    and 1 when the model is certain either way.
    """

    type: Literal["noul"] = "noul"
    noul: float
    confidence: float


class ChoiceAnswer(BaseModel):
    """Answer to a `choice` question.

    `choice` is the winning option key. `confidence` is 1 minus the normalized entropy of the
    probabilities (0 when uniform, 1 when certain), and `probabilities` holds the score of every
    option.
    """

    type: Literal["choice"] = "choice"
    choice: str
    confidence: float
    probabilities: dict[str, float]


class ScoreAnswer(BaseModel):
    """Answer to a `score` question.

    `score` is the 0-based index of the most likely level. `expected_level` is the
    probability-weighted average index, so it can be fractional (1.4 means between level 1 and level
    2). `legend` maps each index back to its description, and `probabilities` is keyed by the same
    index strings.
    """

    type: Literal["score"] = "score"
    score: int
    expected_level: float
    confidence: float
    probabilities: dict[str, float]
    legend: dict[str, str]


Answer = NoulAnswer | ChoiceAnswer | ScoreAnswer


class SystemOneResponse(BaseModel):
    """Body returned by `POST /v1/systemone`.

    `model` is the id of the local model that answered. `answers` has one entry per question in the
    request, under the same name.
    """

    model_config = ConfigDict(protected_namespaces=())

    model: str
    answers: dict[str, Answer]

