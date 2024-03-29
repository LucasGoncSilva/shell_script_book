#!/bin/bash

echo "
    __ __                                      __               __
.--|  |__|.---.-.-----.-----.-----.    .-----.|  |_.---.-.----.|  |_
|  _  |  ||  _  |     |  _  |  _  |    |__ --||   _|  _  |   _||   _|
|_____|  ||___._|__|__|___  |_____|____|_____||____|___._|__|  |____|
     |___|            |_____|    |______|

An automated script to start a Django project
"

printf "Name of the virtual enviroment (creating if inexistent): "
read VENV

printf "Name of the project: "
read PROJECT_NAME

printf "Name of the first app: "
read APP_NAME

FILES=$(ls)


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
                                        the execution is the same


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

echo "-r requirements/prod.txt" > .\\requirements.txt


python -m pip freeze > .\\requirements\\prod.txt


printf '\n\nAbout to start a new Django project...\n\n'
printf "\n\nProject name = ${PROJECT_NAME}\n"
echo "First app name = ${APP_NAME}"


# Deploy stuff
echo "Creating files for deploy"

echo "python-3.11.2" > .\\runtime.txt
echo "web: gunicorn ${PROJECT_NAME^^}.wsgi" > .\\Procfile
echo "{
  \"builds\": [
    {
      \"src\": \"${PROJECT_NAME^^}/wsgi.py\",
      \"use\": \"@vercel/python\"
    },
    {
      \"src\": \"deploy.sh\",
      \"use\": \"@vercel/static-build\",
      \"config\": {
        \"distDir\": \"staticfiles\"
      }
    }
  ],
  \"routes\": [
    {
      \"src\": \"/(.*)\",
      \"dest\": \"${PROJECT_NAME^^}/wsgi.py\"
    }
  ]
}
" >> .\\vercel.json

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
find .gitignore -delete
find LICENSE -delete
find tests/* tests/.*  -delete
rmdir tests
find requirements/* requirements/.*  -delete
rmdir requirements


echo \"

Ending deploy build\"
echo \"___________________________\"

" >> deploy.sh


# Enviroment variable settings
echo "from os import environ, system
from sys import argv


environ['DEBUG'] = 'True'
environ['ALLOWED_HOSTS'] = '*,127.0.0.1,localhost'
environ['DJANGO_SETTINGS_MODULE'] = '${PROJECT_NAME^^}.settings.base'

# environ['EMAIL_HOST_USER'] = ''
# environ['EMAIL_HOST_PASSWORD'] = ''


if argv[1] == 'runserver' and environ.get('DEBUG') == 'False':
    system('py manage.py collectstatic --noinput')
elif argv[1] == 'test':
    environ['DEBUG'] = 'False'
    system('py manage.py collectstatic --noinput')

system('py manage.py ' + ' '.join([i for i in argv[1:]]))
" > .\\orchestrator.py


# Starting project
printf "\n\nStarting project '${PROJECT_NAME}'...\n"

django-admin startproject ${PROJECT_NAME^^} .

echo "${PROJECT_NAME} created successfully."
echo "Starting app '${APP_NAME}' now..."


# Starting app
python ./manage.py startapp $APP_NAME

echo "Setting '${APP_NAME}' as an installed app and creating it url address"

mkdir static templates


# Editing settings.py
sed -i -e "14 i \\\nfrom os import environ\n\n\n## VIRTUAL ENVIROMENTS ACCESSIBLES USING `environ[\'var_name\']`\n" .\\${PROJECT_NAME^^}\\settings.py
sed -i "22s/.*/BASE_DIR = Path(__file__).resolve().parent.parent.parent/" .\\${PROJECT_NAME^^}\\settings.py
sed -i "32s/.*/DEBUG = environ.get('DEBUG', False)/" .\\${PROJECT_NAME^^}\\settings.py
sed -i "34s/.*/ALLOWED_HOSTS = environ.get('ALLOWED_HOSTS').split(',')/" .\\${PROJECT_NAME^^}\\settings.py
sed -i "40 i \    # Default" .\\${PROJECT_NAME^^}\\settings.py
sed -i "47 i \    # 3rd party" .\\${PROJECT_NAME^^}\\settings.py
sed -i "48 i \    'whitenoise'," .\\${PROJECT_NAME^^}\\settings.py
sed -i "49 i \    # Local" .\\${PROJECT_NAME^^}\\settings.py
sed -i "50 i \    '${APP_NAME}'," .\\${PROJECT_NAME^^}\\settings.py
sed -i "55 i \    'whitenoise.middleware.WhiteNoiseMiddleware'," .\\${PROJECT_NAME^^}\\settings.py
sed -i "69s/.*/        'DIRS': [BASE_DIR / 'templates'],/" .\\${PROJECT_NAME^^}\\settinggs.py
sed -i "131 i \STATIC_ROOT = BASE_DIR / 'staticfiles'" .\\${PROJECT_NAME^^}\\settings.py
sed -i "132 i \STATICFILES_STORAGE = 'whitenoise.storage.CompressedManifestStaticFilesStorage'" .\\${PROJECT_NAME^^}\\settings.py
sed -i "133 i \STATICFILES_DIRS = [BASE_DIR / 'static']" .\\${PROJECT_NAME^^}\\settings.py


# Editing urls.py
sed -i '17s/.*/from django.urls import path, include/' .\\${PROJECT_NAME^^}\\urls.py
sed -i "21 i \    path('${APP_NAME}/', include('${APP_NAME}.urls'))," .\\${PROJECT_NAME^^}\\urls.py
sed -i "21 i \    # User's routes" .\\${PROJECT_NAME^^}\\urls.py
sed -i "20 i \    # Adm's routes" .\\${PROJECT_NAME^^}\\urls.py
sed -i "20 i \    # System's routes" .\\${PROJECT_NAME^^}\\urls.py


# Editing asgi.py and wsgi.py
sed -i "14s/.*/os.environ.setdefault('DJANGO_SETTINGS_MODULE', '${PROJECT_NAME^^}.settings.deploy')/" .\\${PROJECT_NAME^^}\\wsgi.py
sed -i "14s/.*/os.environ.setdefault('DJANGO_SETTINGS_MODULE', '${PROJECT_NAME^^}.settings.deploy')/" .\\${PROJECT_NAME^^}\\asgi.py


# Editing manage.py
sed -i "9s/.*/    os.environ.setdefault('DJANGO_SETTINGS_MODULE', '${PROJECT_NAME^^}.settings.deploy')/" .\\manage.py


# Separating dev and deploy settings/config
mkdir .\\${PROJECT_NAME}\\settings

mv .\\${PROJECT_NAME}\\settings.py .\\${PROJECT_NAME}\\settings\\base.py

echo "
# Custom User model

# AUTH_USER_MODEL = 'account.User'
# LOGOUT_REDIRECT_URL = 'conta/entrar'


# Crispy Forms

# CRISPY_TEMPLATE_PACK = 'bootstrap4'


# E-mail configs

# EMAIL_BACKEND = 'django.core.mail.backends.smtp.EmailBackend'
# EMAIL_HOST = 'smtp.gmail.com'
# EMAIL_PORT = 587
# EMAIL_USE_TLS = True
# EMAIL_HOST_USER = environ['EMAIL_HOST_USER']
# EMAIL_HOST_PASSWORD = environ['EMAIL_HOST_PASSWORD']


# Messages configs for bootstrap alerts

# MESSAGE_TAGS = {
#     messages.DEBUG: 'alert-primary',
#     messages.INFO: 'alert-info',
#     messages.SUCCESS: 'alert-success',
#     messages.WARNING: 'alert-warning',
#     messages.ERROR: 'alert-danger',
# }
" >> .\\${PROJECT_NAME}\\settings\\base.py

echo "from os import environ

from ${PROJECT_NAME^^}.settings.base import *


DATABASES = {
    # 'default': URL
    'default': {
        'ENGINE': 'django.db.backends.postgresql',
        'NAME': environ.get('DB_NAME'),
        'USER': environ.get('DB_USER'),
        'PASSWORD': environ.get('DB_PASSWORD'),
        'HOST': environ.get('DB_HOST'),
        'PORT': '5432',
    }
}

DEBUG = environ.get('DEBUG')
ALLOWED_HOSTS = environ.get('ALLOWED_HOSTS').split(',')
SECRET_KEY = environ.get('SECRET_KEY')


SECURE_PROXY_SSL_HEADER = ('HTTP_X_FORWARDED_PROTO', 'https')
SECURE_SSL_REDIRECT = True
" > .\\${PROJECT_NAME}\\settings\\deploy.py


# Creating apps's view as function
echo "Creating index view function..."

cd .\\${APP_NAME}

echo "from django.urls import path, URLPattern

from . import views

app_name = '${APP_NAME}'

urlpatterns: list[URLPattern] = [
    path('', views.index, name='index'),
]
" > .\\urls.py

echo "def index(req: HttpRequest) -> HttpResponse:
    pass
" >> .\\views.py

echo "If using vercel, deal with db and asgi/wsgi app var name
Remember using 'py orchestrator.py check --deploy'"

echo 'Script completed! Hope you know to continue... :D'
