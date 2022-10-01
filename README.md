![The project's banner](https://github.com/LucasGoncSilva/shell_script_book/blob/main/readme_banner.svg?raw=true)


<h1 align='center'>:notebook: Shell Script Book :notebook:</h1>


<h4 align='justify'>A collection of Shell Script's files for make things easier.</h4>


![GitHub last commit](https://img.shields.io/github/last-commit/LucasGoncSilva/shell_script_book?style=for-the-badge)
![Lines of code](https://img.shields.io/tokei/lines/github/LucasGoncSilva/shell_script_book?label=project%27s%20total%20lines&style=for-the-badge)
![GitHub code size in bytes](https://img.shields.io/github/languages/code-size/LucasGoncSilva/shell_script_book?color=4717f6&style=for-the-badge)


<br>


![GitHub language count](https://img.shields.io/github/languages/count/LucasGoncSilva/shell_script_book?color=a903fc&style=for-the-badge)
![GitHub top language](https://img.shields.io/github/languages/top/LucasGoncSilva/shell_script_book?style=for-the-badge)


<br>
<hr>


<h2 align='center'>:chart_with_upwards_trend: Project's Status :chart_with_upwards_trend:</h2>


<p align='center'>
<img align='center' src='https://img.shields.io/badge/-work%20in%20progress%20as%20needed...-fb0?style=for-the-badge'/>
<p>


<br>
<hr>


<h2 align='center'>:star: Features :star:</h2>


- [x] Criação de estrutura inicial de projeto web Django - [django_start.sh](#django_start.sh)


<br>
<hr>


<h2>Pré-requisitos :books: </h2>

Local:
<ul>
<li>Git</li>
<li>Shell Script interpreter</li>
</ul>


<br>
<hr>


<h2 align='center'>:compass: Using :crystal_ball:</h2>


<h3>Cloning and starting</h3>

Clone this repo and access it's dir
```cmd
git clone git@github.com:LucasGoncSilva/shell_script_book.git

cd shell_script_book

```
Then execute any script below:


<hr>
<br>


<h3>django_start.sh</h3>

```bash
.\django_start.sh    <VIRTUAL_ENV>    <PROJECT_NAME>   <FIRST_APP_NAME>   <PATH>
```
* VIRTUAL_ENV: __REQUIRED__. Activates or create a virtual enviroment using it's name
* PROJECT_NAME: __REQUIRED__. Project's name, with all settings
* FIRST_APP_NAME: __REQUIRED__. First app's name, not-empty route using function-based-view
* PATH: __OPTIONAL__. This path is going to be this script's endpoint

This script will create all base structure for a new Django project and it first app, declaring it inside `INSTALLED_APPS`, following some deploy's best practices and preparing the app.

```bash
./django_start.sh env cripto pricing
```

```python
# Project's settings.py

# ...

INSTALLED_APPS = [
    # Default
    ...
    # 3rd party
    'whitenoise',  # App installed for running on prod
    # Local
    'pricing',  # Your app
]

# ...

```

The app's model used here is `include('app.urls')`:

```python
# Project's urls.py

from django.contrib import admin
from django.urls import path, include


urlpatterns = [
    # Adm's routes for adm's pages
    path('admin/', admin.site.urls),
    # System's routes for system's self use, like APIs
    # ...
    # User's routes for common uses
    path('pricing/', include('pricing.urls')),
]

```

On app's dir, created by the script, `urls.py` is created automatically:

```python
# App's urls.py

from django.urls import path
from . import views


app_name = 'pricing'

urlpatterns = [
    path('', views.index, name='index'),
]

```

Finally, on app's `views.py`, this script creates `index` function using `pass`; `HttpResponse()` or `render()`, for example, depends on you:

```python
from django.shortcuts import render


# Create your views here.
def index(request):
    pass

```


<br>
<hr>


<h3 align='center'>:warning: WARNINGS :warning:</h3>


<ul>
<li></li>
<li></li>
<li></li>
</ul>