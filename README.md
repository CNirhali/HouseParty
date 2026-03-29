# HousePartyApp (Zomato District Clone)

A modern, highly-sophisticated house party booking application built with **Flutter** (Frontend) and **FastAPI** (Backend).

## Architecture

*   **Mobile Frontend:** Flutter (Simultaneous iOS/Android support)
*   **Web Mock Frontend:** Vanilla HTML/JS/CSS (For Demo purposes)
*   **Backend:** Python 3.11 with FastAPI 
*   **Database:** SQLite via SQLAlchemy (Designed to mirror PostgreSQL/PostGIS)

## Features
- **Discovery Engine:** Map-based view of house parties, filtered by vibe (Chill, Techno, Game Night, BYOB).
- **Trust & Safety:** Digital Doorbell where the host must approve guests.
- **Secret Address:** The exact house location is hidden and only revealed after a booking is successful.

## How to Run Locally

### 1. Starting the Backend
The backend powers the logic, including fake geolocation distances and booking states.
```bash
cd backend
python -m venv venv
# Activate venv: .\venv\Scripts\Activate.ps1 (Windows) or source venv/bin/activate (Mac/Linux)
pip install -r requirements.txt # (fastapi, uvicorn, pydantic, sqlalchemy)
python -m uvicorn main:app --port 8000
```
*You can access the API Swagger docs at `http://localhost:8000/docs`*

### 2. Starting the Flutter Mobile App
Requires the [Flutter SDK](https://docs.flutter.dev/get-started/install) to be installed.
```bash
cd frontend
flutter pub get
flutter run
```

### 3. Running the Web Demo Mock
If you don't have Flutter installed, you can visualize the app using the web UI simulator. Make sure the backend (`main:app`) is running first.
```bash
cd frontend_web
python -m http.server 8080
```
Open `http://localhost:8080` in your web browser.

---
*Authored during an end-to-end AI software generation process.*