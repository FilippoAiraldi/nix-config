"""Translates GLiDE-style questions into a GLiNER2.5-Decide classification schema."""

from __future__ import annotations

import json
from typing import Any, Protocol

from gliner2.classification import ClassificationSchema

from .schemas import (
    Answer,
    ChoiceAnswer,
    ChoiceQuestion,
    NoulAnswer,
    NoulQuestion,
    Question,
    ScoreAnswer,
    ScoreQuestion,
    State,
)

DEFAULT_NOUL_CRITERIA = {"true": "Yes", "false": "No"}


class ClassifierLike(Protocol):
    def classify(self, text: str, schema: ClassificationSchema) -> Any: ...


def render_state(state: State) -> str:
    """Flatten a string / object / array state into the text the model reads."""
    if isinstance(state, str):
        return state
    if isinstance(state, dict):
        return "\n".join(f"{key}: {_render_value(value)}" for key, value in state.items())
    return "\n".join(_render_value(item) for item in state)


def _render_value(value: Any) -> str:
    return value if isinstance(value, str) else json.dumps(value, ensure_ascii=False)


def build_schema(questions: dict[str, Question]) -> ClassificationSchema:
    """All questions go into one schema so the encoder runs once per request.

    Raises `gliner2.classification.SchemaError` for strings the model prompt
    cannot carry (e.g. parentheses).
    """
    schema = ClassificationSchema()
    for name, question in questions.items():
        kwargs: dict[str, Any] = {}
        if question.instructions:
            kwargs["instruction"] = question.instructions
        if isinstance(question, NoulQuestion):
            criteria = DEFAULT_NOUL_CRITERIA | (question.criteria or {})
            schema.single(name, [criteria["true"], criteria["false"]], **kwargs)
        elif isinstance(question, ChoiceQuestion):
            schema.single(name, question.criteria, **kwargs)
        else:
            # Level descriptions double as label names; the index is recovered by position.
            schema.ordinal(name, question.criteria, **kwargs)
    return schema


def _margin(probabilities: list[float]) -> float:
    top = sorted(probabilities, reverse=True)
    return top[0] - top[1]


def _answer(name: str, question: Question, result: Any) -> Answer:
    probs = dict(result.probabilities(name))
    if isinstance(question, NoulQuestion):
        criteria = DEFAULT_NOUL_CRITERIA | (question.criteria or {})
        p_true, p_false = probs[criteria["true"]], probs[criteria["false"]]
        noul = p_true / (p_true + p_false) if (p_true + p_false) > 0 else 0.5
        return NoulAnswer(noul=noul, confidence=abs(2 * noul - 1))

    if isinstance(question, ChoiceQuestion):
        keys = list(question.criteria)
        values = [probs[key] for key in keys]
        return ChoiceAnswer(
            choice=keys[values.index(max(values))],
            confidence=_margin(values),
            probabilities=dict(zip(keys, values)),
        )

    assert isinstance(question, ScoreQuestion)
    values = [probs[level] for level in question.criteria]
    return ScoreAnswer(
        score=values.index(max(values)),
        expected_level=sum(i * p for i, p in enumerate(values)),
        confidence=_margin(values),
        probabilities={str(i): p for i, p in enumerate(values)},
        legend={str(i): level for i, level in enumerate(question.criteria)},
    )


def decide(
    classifier: ClassifierLike, state: State, questions: dict[str, Question]
) -> dict[str, Answer]:
    result = classifier.classify(render_state(state), build_schema(questions))
    return {name: _answer(name, question, result) for name, question in questions.items()}
