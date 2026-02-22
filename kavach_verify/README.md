# KavachVerify

AI-powered safety verification platform with a Flutter mobile app and a FastAPI backend.

## Project Structure

```
kavach_verify/
├── backend/         ← Python / FastAPI server
├── frontend/        ← Flutter mobile app
├── kavach-redirect/ ← Redirect page
└── README.md
```

## Backend

The backend is a **FastAPI** application that handles AI analysis, report generation, and WhatsApp bot integration.

### Run locally

```bash
cd backend
pip install -r requirements.txt
uvicorn main:app --reload
```

### Deploy to Render

The `Procfile` is already configured:

```
web: uvicorn main:app --host 0.0.0.0 --port $PORT
```

Set the environment variables from `backend/.env` in your Render dashboard.

## Frontend

The frontend is a **Flutter** application.

### Run locally

```bash
cd frontend
flutter pub get
flutter run
```

> **Note:** Update the API base URL in `lib/services/api_service.dart` to point to your deployed Render URL when moving off localhost.
