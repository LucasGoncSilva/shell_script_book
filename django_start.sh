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

python3 -m pip install django
python3 -m pip install whitenoise
python3 -m pip install gunicorn
python3 -m pip install psycopg2-binary





printf "

===========================================================================
Creating devops files
===========================================================================
"

echo "Django==5.0
gunicorn==21.2.0
psycopg2-binary==2.9.9
whitenoise==6.6.0" > requirements.txt

echo "python3-3.11.2" > runtime.txt
echo "web: gunicorn CORE.wsgi" > Procfile
wget "https://lucasgoncsilva.github.io/snippets/examples/vercel/deploy/DJANGO_vercel.json" -O vercel.json

echo "echo \"

Starting deploy build\"
echo \"___________________________\"


echo \"
___________________________\"
echo \"Downloading requirements\"
echo \"___________________________\"
python3.9 -m pip install -r requirements.txt


echo \"
___________________________\"
echo \"Migrating DB\"
echo \"___________________________\"
python3.9 manage.py makemigrations
python3.9 manage.py migrate


echo \"
___________________________\"
echo \"Collecting static files (css, img, js)\"
echo \"___________________________\"
python3.9 manage.py collectstatic --noinput --clear


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
Starting project ${PROJECT_NAME}
===========================================================================
"

mkdir ${PROJECT_NAME^^}
cd ${PROJECT_NAME^^}

django-admin startproject CORE .





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

wget "https://lucasgoncsilva.github.io/snippets/examples/python/django/CUSTOM_USERS_settings.py" -O ->> CORE/settings/base.py
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

echo "If using vercel, deal with db and asgi/wsgi app var name
Remember using 'py orchestrator.py check --deploy'"
