<h1>Shell Script Book :newspaper: </h1>

<h4 align='justify'>Uma pequena coleção de arquivos shell script que possuem o objetivo de facilitar ou automatizar tarefas específicas.</h4>

<br>

<h2>Status do Projeto :chart_with_upwards_trend: </h2>

:construction: Em andamento (conforme necessidades) :construction:

<br>

<h2>Tecnologias aplicadas :floppy_disk: :cloud: </h2>

<ul>
<li>Shell Script</li>
</ul>

<br>

<h2>Features :star: </h2>

- [x] Criação de estrutura inicial de projeto web Django - [new_django_project.sh](#new_django_project)

<br>

<h2>Pré-requisitos :books: </h2>

Local:
<ul>
<li>Git</li>
<li>Interpretador Shell</li>
<li>Demais requisitos a depender do projeto</li>
</ul>

<br>

<h2>Utilização :crystal_ball: </h2>

<h3>Clonando e iniciando</h3>

Clone o repositório e acesse a pasta criada para ele
```cmd
git clone git@github.com:LucasGoncSilva/some_shell_scripts.git

cd some_shell_scripts

```
Em seguida, escolha o script abaixo conforme a necessidade do projeto:

<br>

<h3>new_django_project</h3>

```bash
.\new_django_project    <VIRTUAL_ENV>    <PROJECT_NAME>   <FIRST_APP_NAME>   <PATH>
```
* VIRTUAL_ENV: __Argumento obrigatório__. Ativará este ambiente para a inicialização do projeto em questão; caso o ambiente passado não exista, será criado um, juntamente com a instalação padrão do Django
* PROJECT_NAME: __Argumento obrigatório__. Será o nome do projeto, onde ficarão todos os arquivos de configuração padrão
* FIRST_APP_NAME: __Argumento obrigatório__. Será o nome do primeiro app, com rota definida e view index criada
* PATH: __Argumento opcional__. Caso seja passado, será o endpoint de todas as saídas do script, ou seja, onde o projeto será criado. Nada sendo passado, o script será executado no diretório atual

Este script criará toda a estrutuda básica de um projeto Django com seu primeiro app, declarando-o dentro de `INSTALLED_APPS`.

```python
# settings.py do diretório do projeto

# ...

INSTALLED_APPS = [
    'api', # linha inserida pelo script, instalando o app 'api'
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
]

# ...

```

O modelo de app considerado aqui é com `include('app.urls')`:

```python
# urls.py do diretório do projeto

from django.contrib import admin
from django.urls import path, include
#                               ^^
#                       inserido pelo script

urlpatterns = [
    path('admin/', admin.site.urls),
    path('api/', include('api.urls')),
    # ^^   ^^       ^^        ^^
    # linha criada pelo script inserindo
    # um app chamado api
]

```

Na pasta do app, criado após ser passado como argumento do script, o arquivo `urls.py` é automaticamente criado da maneira a seguir:

```python
# urls.py do diretório do app

from django.urls import path
from . import views

app_name = 'api' # linha definida pelo script

urlpatterns = [
    path('', views.index, name='index'),
    #   ^^^^       ^^^^
    # rota padrão carregando a função index
]

```

Finalmente, em `views.py` no diretório do app, o script cria a função index com `pass` definido, visto que aqui se define o HttpResponse() ou render(), a depender da necessidade:

```python
from django.shortcuts import render

# Create your views here.
def index(request):
    pass

```