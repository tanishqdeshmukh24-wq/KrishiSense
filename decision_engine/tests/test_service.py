from decision_engine.service import evaluate_decision


def test_service_returns_json_ready_decision():
    result = evaluate_decision(
        {
            "soil_moisture": 20,
            "crop": "tomato",
            "growth_stage": "flowering",
        }
    )

    assert result == {
        "decision": "IRRIGATE",
        "priority": "HIGH",
        "reason": "Soil moisture is below the configured irrigation threshold.",
    }
