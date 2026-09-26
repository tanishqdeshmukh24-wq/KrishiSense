from .models import DecisionInput, DecisionResult


# Demo/MVP thresholds.
# These are configurable values, not universal agronomic recommendations.
DEFAULT_MIN_SOIL_MOISTURE = 30.0
DEFAULT_MAX_SOIL_MOISTURE = 70.0


def evaluate_irrigation(
    data: DecisionInput,
    min_soil_moisture: float = DEFAULT_MIN_SOIL_MOISTURE,
    max_soil_moisture: float = DEFAULT_MAX_SOIL_MOISTURE,
) -> DecisionResult:
    """Evaluate irrigation need using soil-moisture rules."""

    if data.soil_moisture is None:
        return DecisionResult(
            decision="INSUFFICIENT_DATA",
            priority="LOW",
            reason="Soil moisture data is unavailable.",
        )

    if not 0 <= data.soil_moisture <= 100:
        return DecisionResult(
            decision="INSUFFICIENT_DATA",
            priority="LOW",
            reason="Soil moisture value is outside the valid 0–100% range.",
        )

    if data.soil_moisture < min_soil_moisture:
        return DecisionResult(
            decision="IRRIGATE",
            priority="HIGH",
            reason="Soil moisture is below the configured irrigation threshold.",
        )

    if data.soil_moisture > max_soil_moisture:
        return DecisionResult(
            decision="WAIT",
            priority="LOW",
            reason="Soil moisture is above the configured range.",
        )

    return DecisionResult(
        decision="WAIT",
        priority="LOW",
        reason="Soil moisture is within the configured range.",
    )
