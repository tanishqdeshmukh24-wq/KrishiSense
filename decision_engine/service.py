"""Backend-facing adapter for the KrishiSense decision engine."""

from typing import Any, Mapping

from .engine import make_decision
from .models import DecisionInput


def evaluate_decision(payload: Mapping[str, Any]) -> dict[str, str]:
    """
    Convert a backend payload into a DecisionInput and return a JSON-ready result.

    The backend remains responsible for HTTP, authentication, persistence and
    hardware integration. This module only provides the decision-engine boundary.
    """

    data = DecisionInput(
        soil_moisture=payload.get("soil_moisture"),
        crop=payload.get("crop"),
        growth_stage=payload.get("growth_stage"),
        temperature=payload.get("temperature"),
        humidity=payload.get("humidity"),
        rainfall=payload.get("rainfall"),
    )

    result = make_decision(data)

    return {
        "decision": result.decision,
        "priority": result.priority,
        "reason": result.reason,
    }
