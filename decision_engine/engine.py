from .models import DecisionInput, DecisionResult
from .rules import evaluate_irrigation


def make_decision(data: DecisionInput) -> DecisionResult:
    """
    Generate a farming decision from available field data.

    The current MVP focuses on irrigation using soil moisture.
    """

    return evaluate_irrigation(data)


if __name__ == "__main__":
    sample = DecisionInput(
        soil_moisture=25.0,
        crop="tomato",
        growth_stage="flowering",
    )

    result = make_decision(sample)

    print(result)