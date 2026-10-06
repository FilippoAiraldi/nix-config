from types import MappingProxyType

import pytest
from fastapi.testclient import TestClient

from app.api import app


class FakeResult:
    def __init__(self, probs):
        self._probs = probs

    def probabilities(self, task):
        return MappingProxyType(self._probs[task])


class FakeClassifier:
    def __init__(self, probs):
        self.probs = probs
        self.calls = []

    def classify(self, text, schema):
        self.calls.append((text, schema))
        return FakeResult(self.probs)


@pytest.fixture
def client():
    fake = FakeClassifier(
        {
            "refund_allowed": {"Qualifies": 0.9, "Does not qualify": 0.1},
            "department": {"billing": 0.1, "returns": 0.8, "shipping": 0.1},
            "urgency": {"low": 0.6, "medium": 0.3, "high": 0.1},
        }
    )
    app.state.classifier = fake
    with TestClient(app) as c:
        c.fake = fake
        yield c
    app.state.classifier = None


BODY = {
    "model": "fastino/GLiDE",
    "state": {"message": "My card was charged twice.", "order_id": "A-104"},
    "questions": {
        "refund_allowed": {
            "type": "noul",
            "instructions": "Does this request qualify for a refund?",
            "criteria": {"true": "Qualifies", "false": "Does not qualify"},
        },
        "department": {
            "type": "choice",
            "criteria": {
                "billing": "Money",
                "returns": "Returns",
                "shipping": "Delivery",
            },
        },
        "urgency": {"type": "score", "criteria": ["low", "medium", "high"]},
    },
}


def test_health(client):
    assert client.get("/health").status_code == 200


def test_systemone(client):
    r = client.post("/v1/systemone", json=BODY)
    assert r.status_code == 200, r.text
    answers = r.json()["answers"]

    assert answers["refund_allowed"]["type"] == "noul"
    assert answers["refund_allowed"]["noul"] == pytest.approx(0.9)
    assert answers["refund_allowed"]["confidence"] == pytest.approx(0.531004, rel=1e-3)

    assert answers["department"]["choice"] == "returns"
    assert answers["department"]["confidence"] == pytest.approx(0.418328, rel=1e-3)

    urgency = answers["urgency"]
    assert urgency["score"] == 0
    assert urgency["expected_level"] == pytest.approx(0.5)
    assert urgency["confidence"] == pytest.approx(0.182654, rel=1e-3)
    assert urgency["legend"] == {"0": "low", "1": "medium", "2": "high"}
    assert list(urgency["probabilities"]) == ["0", "1", "2"]

    # one model call for all questions, with the state rendered as text
    assert len(client.fake.calls) == 1
    assert client.fake.calls[0][0] == "message: My card was charged twice.\norder_id: A-104"


def test_invalid_requests(client):
    assert client.post("/v1/systemone", json={**BODY, "state": ""}).status_code == 422
    assert client.post("/v1/systemone", json={**BODY, "questions": {}}).status_code == 422
    bad = {"state": "x", "questions": {"q": {"type": "choice", "criteria": {"a": "x"}}}}
    assert client.post("/v1/systemone", json=bad).status_code == 422


def test_unsupported_prompt_characters(client):
    body = {
        "state": "x",
        "questions": {"q": {"type": "choice", "criteria": {"a": "has (parens)", "b": "ok"}}},
    }
    assert client.post("/v1/systemone", json=body).status_code == 422

