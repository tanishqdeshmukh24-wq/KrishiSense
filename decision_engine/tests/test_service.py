from decision_engine.service import evaluate_decision


def test_backend_payload_returns_irrigation_decision():
    result = evaluate_decision({
        "soil_moisture": 20,
        "crop": "tomato",
        "growth_stage": "flowering",
    })

    assert result == {
        "decision": "IRRIGATE",
        "priority": "HIGH",
        "reason": "Soil moisture is below the configured irrigation threshold.",
    }


def test_backend_payload_handles_missing_moisture():
    result = evaluate_decision({
        "crop": "tomato",
        "growth_stage": "flowering",
    })

    assert result["decision"] == "INSUFFICIENT_DATA"
