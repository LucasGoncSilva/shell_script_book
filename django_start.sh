#!/bin/bash

if [[ -z $3 ]]
then
    echo "Must pass 3 args:


{{ script }}      <VENV>       <PROJECT_NAME>        <FIRST_APP_NAME>
                    ^^^              ^^^                    ^^^
                Venv's name     Project's name        First app's name
             (existing or not,                      (www.project.com/app)
             like 'venv_django'                                      ^^
             with no bar or dot)                              not empty route



You're able to pass a path as 4th arg to execute this script:

{{ script }} VENV    PROJECT_NAME    FIRST_APP_NAME    PATH_TO_DESTINATION
                                                                ^^
                                                           not required


"
    echo "Press enter and retry"
    read ok
    exit
fi


VENV=$1
PROJECT_NAME=$2
APP_NAME=$3
FILES=$(ls)


# Checking if there is a path
if [[ $4 ]]
then
    cd $4
fi


if [[ ${FILES} != *"${PROJECT_NAME}"* ]]
then
    mkdir ${PROJECT_NAME}
    cd ${PROJECT_NAME}

else
    cd ${PROJECT_NAME}
fi


FILES=$(ls)


if [[ ${FILES} != *"${VENV}"* ]]
then
    echo "The passed virtual enviroment's name does not exist here."
    echo "Creating a venv using the passed name"
    python -m venv ${VENV}
    printf "Virtual enviroment created.\n\n\n"
fi


# orchestrator.py warning

echo "After this script, for correct use of environment variables,
remember to run orchestrator.py instead of manage.py

Reason: orchestrator.py is going to set all the enviroment variables
and then calling manage.py using shell, also using the args


e.g. python manage.py migrate --> --> python orchestrator.py migrate
                                                    ^^
                                          the result is the same


Press enter to continue..."
read ok

# Starting the venv
echo "Activating virtual enviroment..."
source .\\${VENV}\\Scripts\\activate
echo "Virtual enviroment activated. Checking for installed packages and"
echo "also installing if necessary."


python -m pip install django
python -m pip install whitenoise
python -m pip install gunicorn
python -m pip install django-environ

python -m pip freeze > .\\requirements.txt


printf '\n\nAbout to start a new Django project...\n\n'
printf "\n\nProject name = ${PROJECT_NAME}\n"
echo "First app name = ${APP_NAME}"


# Deploy stuff
echo "Creating files for Heroku's deploy"

echo "python-3.10.4" > .\\runtime.txt
echo "web: gunicorn INVENTORY.wsgi" > .\\Procfile


# Enviroment variable settings
echo "from os import environ, system
from sys import argv


environ['DEBUG'] = 'True'
environ['SECRET_KEY'] = '---' # Your project's secret key
environ['ALLOWED_HOSTS'] = '*'

system('py .\manage.py ' + ' '.join([i for i in argv[1:]]))" > .\\orchestrator.py


# Starting project
printf "\n\nStarting project '${PROJECT_NAME}'...\n"

django-admin startproject ${PROJECT_NAME^^} .

echo "${PROJECT_NAME} created successfully."
echo "Starting app '${APP_NAME}' now..."


# Starting app
python ./manage.py startapp $APP_NAME

echo "Setting '${APP_NAME}' as an installed app and creating it url address"


# Editing settings.py
sed -i -e "14 i \\\nimport environ\n\n\nenv = environ.Env()\n" .\\${PROJECT_NAME^^}\\settings.py
sed -i "22s/.*/BASE_DIR = Path(__file__).resolve().parent.parent.parent/" .\\${PROJECT_NAME^^}\\settings.py
sed -i "32s/.*/DEBUG = env.bool('DEBUG', False)/" .\\${PROJECT_NAME^^}\\settings.py
sed -i "34s/.*/ALLOWED_HOSTS = env('ALLOWED_HOSTS').split(',')/" .\\${PROJECT_NAME^^}\\settings.py
sed -i "40 i \    # Default" .\\${PROJECT_NAME^^}\\settings.py
sed -i "47 i \    # 3rd party" .\\${PROJECT_NAME^^}\\settings.py
sed -i "48 i \    'whitenoise'" .\\${PROJECT_NAME^^}\\settings.py
sed -i "49 i \    # Local" .\\${PROJECT_NAME^^}\\settings.py
sed -i "50 i \    '${APP_NAME}'," .\\${PROJECT_NAME^^}\\settings.py
sed -i "55 i \    'whitenoise.middleware.WhiteNoiseMiddleware'," .\\${PROJECT_NAME^^}\\settings.py
sed -i "131 i \STATIC_ROOT = BASE_DIR / 'staticfiles'" .\\${PROJECT_NAME^^}\\settings.py
sed -i "132 i \STATICFILES_STORAGE = 'whitenoise.storage.CompressedManifestStaticFilesStorage'" .\\${PROJECT_NAME^^}\\settings.py


# Editing urls.py
sed -i '17s/.*/from django.urls import path, include/' .\\${PROJECT_NAME^^}\\urls.py
sed -i "21 i \    path('${APP_NAME}/', include('${APP_NAME}.urls'))," .\\${PROJECT_NAME^^}\\urls.py


# Editing asgi.py and wsgi.py
sed -i "14s/.*/os.environ.setdefault('DJANGO_SETTINGS_MODULE', '${PROJECT_NAME^^}.settings.base')/" .\\${PROJECT_NAME^^}\\wsgi.py
sed -i "14s/.*/os.environ.setdefault('DJANGO_SETTINGS_MODULE', '${PROJECT_NAME^^}.settings.base')/" .\\${PROJECT_NAME^^}\\asgi.py


# Editing manage.py
sed -i "9s/.*/    os.environ.setdefault('DJANGO_SETTINGS_MODULE', '${PROJECT_NAME^^}.settings.base')/" .\\${PROJECT_NAME^^}\\asgi.py


# Separating dev and deploy settings/config
mkdir .\\${PROJECT_NAME}\\settings

mv .\\${PROJECT_NAME}\\settings.py .\\${PROJECT_NAME}\\settings\\base.py

echo "import environ

from ${PROJECT_NAME^^}.settings.base import *


env = environ.Env()


DATABASES = {
    'default': env.db()
}" > .\\${PROJECT_NAME}\\settings\\deploy.py


# Creating apps's view as function
echo "Creating index view function..."

cd .\\${APP_NAME}

echo "from django.urls import path
from . import views

app_name = '${APP_NAME}'

urlpatterns = [
    path('', views.index, name='index'),
]" > .\\urls.py

echo "def index(request):
    pass" >> .\\views.py

echo 'Script completed! Hope you know to continue... :D'