from decision_engine.engine import make_decision
from decision_engine.models import DecisionInput


def test_irrigate_when_soil_is_dry():
    result = make_decision(DecisionInput(soil_moisture=20))

    assert result.decision == "IRRIGATE"
    assert result.priority == "HIGH"


def test_wait_when_soil_moisture_is_adequate():
    result = make_decision(DecisionInput(soil_moisture=50))

    assert result.decision == "WAIT"
    assert result.priority == "LOW"


def test_insufficient_data_when_moisture_is_missing():
    result = make_decision(DecisionInput())

    assert result.decision == "INSUFFICIENT_DATA"
    assert result.priority == "LOW"


def test_insufficient_data_for_invalid_moisture():
    result = make_decision(DecisionInput(soil_moisture=120))

    assert result.decision == "INSUFFICIENT_DATA"