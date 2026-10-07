"""Translates GLiDE-style questions into a GLiNER2.5-Decide classification schema."""

import json
from collections.abc import Iterable
from math import log
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
    State,
)

DEFAULT_NOUL_CRITERIA = {"true": "Yes", "false": "No"}


class _ClassifierResultLike(Protocol):
    def probabilities(self, task: str) -> dict[str, float]: ...


class _ClassifierLike(Protocol):
    def classify(self, text: str, schema: ClassificationSchema) -> _ClassifierResultLike: ...


def _render_value(value: Any) -> str:
    return value if isinstance(value, str) else json.dumps(value, ensure_ascii=False)


def _render_state(state: State) -> str:
    """Flatten a string, object / array state into the text the model reads."""
    if isinstance(state, str):
        return state
    if isinstance(state, dict):
        return "\n".join(f"{key}: {_render_value(value)}" for key, value in state.items())
    return "\n".join(_render_value(item) for item in state)


def _build_schema(questions: dict[str, Question]) -> ClassificationSchema:
    """All questions go into one schema so the encoder runs once per request."""
    schema = ClassificationSchema()
    for name, question in questions.items():
        kwargs: dict[str, Any] = {}
        if question.instructions:
            kwargs["instruction"] = question.instructions

        match question:
            case NoulQuestion():
                criteria = DEFAULT_NOUL_CRITERIA | (question.criteria or {})
                schema.single(name, [criteria["true"], criteria["false"]], **kwargs)
            case ChoiceQuestion():
                schema.single(name, question.criteria, **kwargs)
            case _:  # ScoreQuestion
                schema.ordinal(name, question.criteria, **kwargs)
    return schema


def _confidence(probabilities: Iterable[float], tol: float = 1e-12) -> float:
    """Return confidence as `1-H(p) / log n`, where `H(p)` is the entropy of the normalized
    probabilities and `n` is the number of classes."""
    if not isinstance(probabilities, (list, tuple)):
        probabilities = list(probabilities)
    if any(p < 0 for p in probabilities):
        raise ValueError("Probabilities must be non-negative.")

    n = len(probabilities)
    if n == 0:
        raise ValueError("At least one probability is required.")
    if n == 1:
        return 1.0

    tot = sum(probabilities)
    if tot <= 0:
        return 0.0
    normalized = (p / tot for p in probabilities)
    return 1.0 + sum(p * log(p) for p in normalized if p > tol) / log(n)


def _answer(name: str, question: Question, result: _ClassifierResultLike) -> Answer:
    """Convert classifier probabilities into the public answer model."""
    probs = result.probabilities(name)

    match question:
        case NoulQuestion():
            criteria = DEFAULT_NOUL_CRITERIA | (question.criteria or {})
            p_true = probs[criteria["true"]]
            p_false = probs[criteria["false"]]
            total = p_true + p_false
            if total <= 0:
                raise ValueError(f"Invalid probabilities for question '{name}': {probs}")
            noul = p_true / total
            return NoulAnswer(noul=noul, confidence=_confidence([p_true, p_false]))

        case ChoiceQuestion():
            probabilities = {criterion: probs[criterion] for criterion in question.criteria}
            choice, _ = max(probabilities.items(), key=lambda x: x[1])
            confidence = _confidence(probabilities.values())
            return ChoiceAnswer(choice=choice, confidence=confidence, probabilities=probabilities)

        case _:  # ScoreQuestion
            probabilities = [probs[level] for level in question.criteria]
            score, _ = max(enumerate(probabilities), key=lambda x: x[1])
            expectation = sum(i * p for i, p in enumerate(probabilities))
            confidence = _confidence(probabilities)
            probs_dict = {str(i): p for i, p in enumerate(probabilities)}
            legend = {str(i): level for i, level in enumerate(question.criteria)}
            return ScoreAnswer(
                score=score,
                expected_level=expectation,
                confidence=confidence,
                probabilities=probs_dict,
                legend=legend,
            )


def decide(
    classifier: _ClassifierLike, state: State, questions: dict[str, Question]
) -> dict[str, Answer]:
    """Classify the state and return one answer for each question.

    Args:
        classifier: Classifier implementation used to evaluate the state.
        state: Input state to render and classify.
        questions: Named questions to evaluate.

    Returns:
        A mapping from question name to its corresponding answer.
    """
    result = classifier.classify(_render_state(state), _build_schema(questions))
    return {name: _answer(name, question, result) for name, question in questions.items()}

