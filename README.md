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
