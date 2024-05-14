#!/bin/bash
cd test

echo "
    __ __                                      __               __
.--|  |__|.---.-.-----.-----.-----.    .-----.|  |_.---.-.----.|  |_
|  _  |  ||  _  |     |  _  |  _  |    |__ --||   _|  _  |   _||   _|
|_____|  ||___._|__|__|___  |_____|____|_____||____|___._|__|  |____|
     |___|            |_____|    |______|

An automated script to start a Django project
"


printf "Name of the project: "
read PROJECT_NAME

printf "Name of the first app: "
read APP_NAME

mkdir ${PROJECT_NAME}
cd ${PROJECT_NAME}












printf "

===========================================================================
CREATING NEW PROJECT WITH DJANGO_START

PROJECT: ${PROJECT_NAME}
PROJECT MAIN DIRECTORY: CORE/
1st APP: ${APP_NAME}
1st APP DIR: ${APP_NAME}/
ENV NAME: env
===========================================================================
"












printf "

===========================================================================
Creating virtual environment and installing dependencies
===========================================================================
"


python3 -m venv env

source env/bin/activate

python3 -m pip install django whitenoise gunicorn psycopg2-binary












printf "

===========================================================================
Creating devops files
===========================================================================
"

echo "-r ./${PROJECT_NAME^^}/requirements.txt

locust
tqdm
pyflakes
black
tblib
coverage" > requirements.dev.txt

echo "python3-3.12" > runtime.txt
echo "web: gunicorn CORE.wsgi" > Procfile
wget "https://lucasgoncsilva.github.io/snippets/examples/vercel/deploy/DJANGO_vercel.json" -O vercel.json

echo "echo \"

Starting deploy build\"
echo \"___________________________\"


echo \"
___________________________\"
echo \"Downloading requirements\"
echo \"___________________________\"
python3 -m pip install -r requirements.txt


echo \"
___________________________\"
echo \"Migrating DB\"
echo \"___________________________\"
python3 manage.py makemigrations
python3 manage.py migrate


echo \"
___________________________\"
echo \"Collecting static files (css, img, js)\"
echo \"___________________________\"
python3 manage.py collectstatic --noinput --clear


echo \"
___________________________\"
echo \"Dealing with unused files (tests, .gitignore, ...)\"
echo \"___________________________\"
find requirements.txt -delete
find LICENSE -delete
find tests/* tests/.* ./*/test*.py test/* -delete


echo \"

Ending deploy build\"
echo \"___________________________\"
" >> deploy.sh












printf "

===========================================================================
Creating Docker stuff
===========================================================================
"

wget "https://lucasgoncsilva.github.io/snippets/examples/python/django/DEPLOY_dockerfile" -O ->> Dockerfile

wget "https://lucasgoncsilva.github.io/snippets/examples/python/django/DEPLOY_docker_compose.yml" -O ->> docker-compose.yml

wget "https://lucasgoncsilva.github.io/snippets/examples/python/django/DEPLOY_docker_compose_dev.yml" -O ->> docker-compose-dev.yml

wget "https://lucasgoncsilva.github.io/snippets/examples/python/django/DEPLOY_docker_compose_unittest.yml" -O ->> docker-compose-unittest.yml

wget "https://lucasgoncsilva.github.io/snippets/examples/python/django/DEPLOY_docker_compose_load.yml" -O ->> docker-compose-load.yml












printf "

===========================================================================
Handling load tests
===========================================================================
"

mkdir loadtests

wget "https://lucasgoncsilva.github.io/snippets/examples/python/django/LOADTESTS_utils.py" -O ->> loadtests/utils.py

wget "https://lucasgoncsilva.github.io/snippets/examples/python/django/LOADTESTS_load_test.py" -O ->> loadtests/load_test.py

wget "https://lucasgoncsilva.github.io/snippets/examples/python/django/LOADTESTS_stress_test.py" -O ->> loadtests/stress_test.py

wget "https://lucasgoncsilva.github.io/snippets/examples/python/django/LOADTESTS_soak_test.py" -O ->> loadtests/soak_test.py

wget "https://lucasgoncsilva.github.io/snippets/examples/python/django/LOADTESTS_spike_test.py" -O ->> loadtests/spike_test.py

mkdir report

mkdir report/html

mkdir report/csv report/csv/spike report/csv/load report/csv/stress report/csv/soak

touch report/csv/soak/.gitkeep report/csv/stress/.gitkeep report/csv/load/.gitkeep report/csv/spike/.gitkeep












printf "

===========================================================================
Attaching tests to GitHub Workflows
===========================================================================
"

mkdir .github .github/workflows

wget "https://lucasgoncsilva.github.io/snippets/examples/python/django/WORKFLOWS_code_analysis.yml" -O ->> .github/workflows/code_analysis.yml

wget "https://lucasgoncsilva.github.io/snippets/examples/python/django/WORKFLOWS_loadtest.yml" -O ->> .github/workflows/loadtest.yml

wget "https://lucasgoncsilva.github.io/snippets/examples/python/django/WORKFLOWS_soaktest.yml" -O ->> .github/workflows/soaktest.yml

wget "https://lucasgoncsilva.github.io/snippets/examples/python/django/WORKFLOWS_spiketest.yml" -O ->> .github/workflows/spiketest.yml

wget "https://lucasgoncsilva.github.io/snippets/examples/python/django/WORKFLOWS_stresstest.yml" -O ->> .github/workflows/stresstest.yml

wget "https://lucasgoncsilva.github.io/snippets/examples/python/django/WORKFLOWS_unittest.yml" -O ->> .github/workflows/unittest.yml












printf "

===========================================================================
Starting project ${PROJECT_NAME}
===========================================================================
"

mkdir ${PROJECT_NAME^^}
cd ${PROJECT_NAME^^}

django-admin startproject CORE .

pip freeze > requirements.txt

pip install -r ../requirements.dev.txt












printf "

===========================================================================
Editting default structure
===========================================================================
"

echo "from django.contrib import admin
from django.urls import path, URLPattern


urlpatterns: list[URLPattern] = [
    # System's routes
    # Admin's routes
    path('admin/', admin.site.urls),
    # User's routes
]" > CORE/urls.py


mkdir CORE/settings
mv CORE/settings.py CORE/settings/base.py

echo "
\"\"\"" >> CORE/settings/base.py

wget "https://lucasgoncsilva.github.io/snippets/examples/python/django/CUSTOM_USER_settings.py" -O ->> CORE/settings/base.py

wget "https://lucasgoncsilva.github.io/snippets/examples/python/django/EMAIL_settings.py" -O ->> CORE/settings/base.py

wget "https://lucasgoncsilva.github.io/snippets/examples/python/django/MESSAGES_settings.py" -O ->> CORE/settings/base.py

echo "\"\"\"" >> CORE/settings/base.py

echo "from os import environ

from CORE.settings.base import *

" > CORE/settings/deploy.py

wget "https://lucasgoncsilva.github.io/snippets/examples/python/django/DEPLOY_deploy.py" -O ->> CORE/settings/deploy.py


echo "import os

from django.core.wsgi import get_wsgi_application


os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'CORE.settings.deploy')

app = application = get_wsgi_application()" > CORE/wsgi.py

echo "import os

from django.core.asgi import get_asgi_application


os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'CORE.settings.deploy')

app = application = get_asgi_application()" > CORE/asgi.py

echo "#!/usr/bin/env python
\"\"\"Django's command-line utility for administrative tasks.\"\"\"
import os
import sys


def main():
    \"\"\"Run administrative tasks.\"\"\"
    os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'CORE.settings.deploy')
    try:
        from django.core.management import execute_from_command_line
    except ImportError as exc:
        raise ImportError(
            \"Couldn't import Django. Are you sure it's installed and \"
            \"available on your PYTHONPATH environment variable? Did you \"
            \"forget to activate a virtual environment?\"
        ) from exc
    execute_from_command_line(sys.argv)


if __name__ == '__main__':
    main()" > manage.py












printf "

===========================================================================
Starting app \"${APP_NAME}\"
===========================================================================
"

python3 manage.py startapp ${APP_NAME}












printf "

===========================================================================
Editting default app's structure
===========================================================================
"

echo "from django.urls import path, URLPattern

from . import views


app_name = '${APP_NAME}'

urlpatterns: list[URLPattern] = [
    path('', views.index, name='index'),
]" > ${APP_NAME}/urls.py

echo "from django.shortcuts import render
from django.http import HttpRequest, HttpResponse


# Create your views here
def index(req: HttpRequest) -> HttpResponse:
    pass" > ${APP_NAME}/views.py

printf "=====DISCLAIMER=====

* If using vercel, deal with db and asgi/wsgi app var name
* Remember using 'py orchestrator.py check --deploy'
* "
