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
    echo "Virtual enviroment created (.\\${VENV})"
fi


echo "Activating virtual enviroment..."
source .\\${VENV}\\Scripts\\activate
echo "Virtual enviroment activated. Checking for installed packages and"
echo "also installing if necessary."

python -m pip install django

printf '\n\nAbout to start a new Django project...\n\n'

printf "\n\nProject name = ${PROJECT_NAME}\n"
echo "First app name = ${APP_NAME}"


# Starting here
printf "\n\nStarting project '${PROJECT_NAME}'...\n"

django-admin startproject ${PROJECT_NAME^^} .

echo "${PROJECT_NAME} created successfully."

echo "Starting app '${APP_NAME}' now..."

python ./manage.py startapp $APP_NAME

echo "Setting '${APP_NAME}' as an installed app and creating it url address"

sed -i "34 i \    '${APP_NAME}'," .\\${PROJECT_NAME^^}\\settings.py

sed -i '17s/.*/from django.urls import path, include/' .\\${PROJECT_NAME^^}\\urls.py
sed -i "21 i \    path('${APP_NAME}/', include('${APP_NAME}.urls'))," .\\${PROJECT_NAME^^}\\urls.py

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