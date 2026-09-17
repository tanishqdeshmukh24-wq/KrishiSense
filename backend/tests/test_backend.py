from datetime import datetime

import pytest
from fastapi.testclient import TestClient

from app.config import get_settings
from app.database import Base, SessionLocal, engine
from app.main import app


@pytest.fixture(autouse=True)
def reset_db():
    Base.metadata.drop_all(bind=engine)
    Base.metadata.create_all(bind=engine)
    yield
    db = SessionLocal()
    db.close()


client = TestClient(app)


def register_and_login():
    email = "farmer@example.com"
    password = "password123"
    register = client.post("/auth/register", json={"name": "Farmer", "email": email, "password": password})
    assert register.status_code == 201
    login = client.post("/auth/login", params={"email": email, "password": password})
    assert login.status_code == 200
    return {"Authorization": f"Bearer {login.json()['access_token']}"}


def test_health():
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json() == {"status": "ok"}


def test_auth_farm_field_zone_crop_node_and_reading_flow():
    headers = register_and_login()
    assert client.get("/auth/me", headers=headers).status_code == 200

    farm = client.post("/farms", headers=headers, json={"name": "Main Farm", "location": "Wardha"})
    assert farm.status_code == 201
    farm_id = farm.json()["id"]

    field = client.post(f"/farms/{farm_id}/fields", headers=headers, json={"farm_id": farm_id, "name": "Field 1", "area_acres": 2.0})
    assert field.status_code == 201
    field_id = field.json()["id"]

    zone = client.post(f"/farms/{farm_id}/fields/{field_id}/zones", headers=headers, json={"field_id": field_id, "name": "Zone 1"})
    assert zone.status_code == 201
    zone_id = zone.json()["id"]

    crop = client.post("/crops", headers=headers, json={"zone_id": zone_id, "name": "Tomato", "growth_stage": "Vegetative"})
    assert crop.status_code == 201

    node = client.post(
        "/nodes",
        headers=headers,
        json={"node_id": "NODE_001", "device_id": "ESP32-001", "farm_id": farm_id, "field_id": field_id, "zone_id": zone_id},
    )
    assert node.status_code == 201
    assert node.json()["status"] == "OFFLINE"

    reading = client.post(
        "/sensor/readings",
        json={"node_id": "NODE_001", "zone_id": zone_id, "soil_moisture": 24.5, "timestamp": datetime.utcnow().isoformat()},
    )
    assert reading.status_code == 201

    node_after_reading = client.get("/nodes/NODE_001", headers=headers)
    assert node_after_reading.status_code == 200
    assert node_after_reading.json()["status"] == "ONLINE"

    history = client.get("/sensor/readings/NODE_001", headers=headers)
    assert history.status_code == 200
    assert len(history.json()) == 1


def test_invalid_sensor_relationship_rejected():
    headers = register_and_login()
    farm = client.post("/farms", headers=headers, json={"name": "Farm"}).json()
    field = client.post(f"/farms/{farm['id']}/fields", headers=headers, json={"farm_id": farm["id"], "name": "Field"}).json()
    zone = client.post(f"/farms/{farm['id']}/fields/{field['id']}/zones", headers=headers, json={"field_id": field["id"], "name": "Zone"}).json()
    other_zone = client.post(f"/farms/{farm['id']}/fields/{field['id']}/zones", headers=headers, json={"field_id": field["id"], "name": "Zone 2"}).json()

    node = client.post("/nodes", headers=headers, json={"node_id": "NODE_1", "device_id": "DEVICE_1", "farm_id": farm["id"], "field_id": field["id"], "zone_id": zone["id"]})
    assert node.status_code == 201

    response = client.post("/sensor/readings", json={"node_id": "NODE_1", "zone_id": other_zone["id"], "soil_moisture": 20, "timestamp": datetime.utcnow().isoformat()})
    assert response.status_code == 400
