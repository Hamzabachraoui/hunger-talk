import uuid
import sys
from pathlib import Path
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.pool import StaticPool
from sqlalchemy.orm import sessionmaker
from sqlalchemy.dialects.postgresql import UUID as PGUUID, ARRAY
from sqlalchemy.ext.compiler import compiles


@compiles(PGUUID, "sqlite")
def compile_uuid_sqlite(type_, compiler, **kw):
    # Stockage binaire pour SQLite lors des tests
    return "BLOB"


@compiles(ARRAY, "sqlite")
def compile_array_sqlite(type_, compiler, **kw):
    return "TEXT"

BACKEND_ROOT = Path(__file__).resolve().parents[1]
if str(BACKEND_ROOT) not in sys.path:
    sys.path.insert(0, str(BACKEND_ROOT))

from main import app  # noqa: E402
from database import Base  # noqa: E402
from app.models.user import User  # noqa: E402
from app.models.stock_item import StockItem  # noqa: E402
from app.models.category import Category  # noqa: E402

# Base de données SQLite en mémoire pour les tests
SQLALCHEMY_DATABASE_URL = "sqlite:///:memory:"
engine = create_engine(
    SQLALCHEMY_DATABASE_URL,
    connect_args={"check_same_thread": False},
    poolclass=StaticPool,
)
TestingSessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)


def override_get_db():
    db = TestingSessionLocal()
    try:
        yield db
    finally:
        db.close()


# Créer uniquement les tables nécessaires aux tests (users, categories, stock_items)
Base.metadata.create_all(bind=engine, tables=[User.__table__, Category.__table__, StockItem.__table__])

# Override de dépendance
app.dependency_overrides = {}
from database import get_db  # noqa: E402
app.dependency_overrides[get_db] = override_get_db

client = TestClient(app)


def test_register_and_login_and_refresh():
    email = f"user_{uuid.uuid4().hex[:8]}@test.com"
    payload = {
        "email": email,
        "password": "Test1234!",
        "first_name": "Test",
        "last_name": "User",
    }

    # Register
    r = client.post("/api/auth/register", json=payload)
    assert r.status_code == 201, r.text
    token = r.json().get("access_token")
    assert token

    # Login
    r = client.post("/api/auth/login", json={"email": email, "password": "Test1234!"})
    assert r.status_code == 200, r.text
    token = r.json()["access_token"]

    # Refresh
    r = client.post("/api/auth/refresh", headers={"Authorization": f"Bearer {token}"})
    assert r.status_code == 200, r.text
    assert r.json().get("access_token")


def test_stock_requires_auth():
    r = client.get("/api/stock")
    assert r.status_code == 401

