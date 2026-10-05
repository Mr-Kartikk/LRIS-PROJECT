# LRIS

LRIS is a Flutter lost-and-found app backed by a Django REST API.

## Requirements

- Flutter with Dart SDK 3.11 or newer
- Python 3.11

## Run the backend on Windows

From the repository root, create an isolated environment, install dependencies,
and prepare the local SQLite database:

```powershell
py -3.11 -m venv lostfound\.venv
lostfound\.venv\Scripts\python.exe -m pip install -r lostfound\requirements.txt
lostfound\.venv\Scripts\python.exe lostfound\manage.py migrate
lostfound\.venv\Scripts\python.exe lostfound\populate_categories.py
lostfound\.venv\Scripts\python.exe lostfound\manage.py runserver 127.0.0.1:8000
```

The development settings use SQLite by default, so PostgreSQL is not required.

## Deploy the backend

GitHub Pages hosts only the Flutter frontend. For people on other computers to
share accounts and data, deploy `lostfound/` to a public HTTPS Django host and
use a persistent database. Configure the backend's `DJANGO_DEBUG=0`,
`DJANGO_SECRET_KEY`, `DJANGO_ALLOWED_HOSTS`, `CORS_ALLOWED_ORIGINS`, and
`CSRF_TRUSTED_ORIGINS` environment variables for your chosen host and the Pages
origin (`https://mr-kartikk.github.io`). Keep secrets on the backend host, never
in this repository.

Then add a GitHub Actions repository variable named `API_BASE_URL` with the
value `https://<backend-host>/api` (no trailing slash), and rerun the
**Deploy Flutter web to GitHub Pages** workflow. The hosted API and database are
separate from your local development database.

## Run the Flutter app

In a second terminal from the repository root:

Make sure Flutter's `bin` directory is on `PATH`. In this workspace it is
`C:\src\flutter\bin`.

```powershell
flutter pub get
flutter run -d chrome
```

The default API URL is `http://127.0.0.1:8000/api`. For an Android emulator,
use its host-machine alias when starting Flutter:

```powershell
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000/api
```
