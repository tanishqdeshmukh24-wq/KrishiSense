# KrishiSense Backend

Core FastAPI backend and database owned by Ninad.

## Stack

- Python + FastAPI
- SQLAlchemy
- SQLite for development/prototype
- JWT authentication for API protection

## Local setup

From the repository root:

```bash
cd backend
python -m venv .venv
```

Windows PowerShell:

```powershell
.\.venv\Scripts\Activate.ps1
pip install -r requirements.txt
Copy-Item .env.example .env
uvicorn app.main:app --reload
```

macOS/Linux:

```bash
source .venv/bin/activate
pip install -r requirements.txt
cp .env.example .env
uvicorn app.main:app --reload
```

The API is available at `http://127.0.0.1:8000`.

Health check:

```text
GET /health
```

Expected response:

```json
{"status":"ok"}
```

The SQLite database file is created automatically on application startup. Do not commit `.env` or generated database files.
