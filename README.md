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

## Make the backend available to other computers

GitHub Pages hosts only the Flutter frontend. To share accounts and data, deploy
the Django API to a public HTTPS host. PythonAnywhere can run this project with
SQLite for a small deployment; the hosted database is separate from your local
`db.sqlite3`, so create accounts again after deployment.

1. Create a PythonAnywhere account and a Python 3.11 web app.
2. In a PythonAnywhere Bash console, clone the repository and initialize the
	backend:

	```bash
	git clone https://github.com/Mr-Kartikk/LRIS-PROJECT.git
	cd LRIS-PROJECT/lostfound
	python3.11 -m venv .venv
	.venv/bin/pip install -r requirements.txt
	.venv/bin/python manage.py migrate
	.venv/bin/python populate_categories.py
	.venv/bin/python manage.py collectstatic --noinput
	```

3. In the PythonAnywhere Web tab, set the virtualenv to
	`/home/<username>/LRIS-PROJECT/lostfound/.venv` and edit the WSGI file. Add
	this configuration before importing `get_wsgi_application`, replacing
	`<username>` and generating a private secret with
	`python -c "import secrets; print(secrets.token_urlsafe(50))"`:

	```python
	import os
	import sys

	project_path = "/home/<username>/LRIS-PROJECT/lostfound"
	sys.path.insert(0, project_path)
	os.environ["DJANGO_SETTINGS_MODULE"] = "lostfound.settings"
	os.environ["DJANGO_SECRET_KEY"] = "<private generated secret>"
	os.environ["DJANGO_DEBUG"] = "0"
	os.environ["DJANGO_ALLOWED_HOSTS"] = "<username>.pythonanywhere.com"
	os.environ["CORS_ALLOWED_ORIGINS"] = "https://mr-kartikk.github.io"
	os.environ["CSRF_TRUSTED_ORIGINS"] = "https://mr-kartikk.github.io,https://<username>.pythonanywhere.com"
	os.environ["USE_SQLITE"] = "1"

	from django.core.wsgi import get_wsgi_application
	application = get_wsgi_application()
	```

4. Add a static-files mapping of `/static/` to
	`/home/<username>/LRIS-PROJECT/lostfound/staticfiles`, then reload the web app.
5. In GitHub, open **Settings > Secrets and variables > Actions > Variables** and
	add `API_BASE_URL` with the value
	`https://<username>.pythonanywhere.com/api` (no trailing slash). Rerun the
	**Deploy Flutter web to GitHub Pages** workflow.

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
