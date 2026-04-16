# CondoFlow App

## Iniciando um novo projeto

### 1. Clonar o repositório

```bash
git clone https://github.com/davigledson/condoflow-app.git
cd condoflow-app
```
### 1.2 crie o arquivo .env.production

```bash
MYAPP_DB_USERNAME=condoflow
MYAPP_DB_PASSWORD=condoflow
MYAPP_DB_HOST=db
RAILS_MASTER_KEY=sua_master_aqui
```

### 1.3 Criar a master.key e o credentials.yml.enc
#### 1.3.1 Remover o arquivo de credentials antigo
```bash
#apague o arquivo:
config/credentials.yml.enc

#linux/ macOS / WSl
rm config/credentials.yml.enc

#windows (PowerShell)
Remove-Item config\credentials.yml.enc

#Windows (CMD)
del config\credentials.yml.enc
```
#### 1.3.2 Depois de apagar o credentials antigo, gere os dois arquivos juntos com:

```bash

rails credentials:edit
```
Esse comando cria:
config/master.key
config/credentials.yml.enc

### 1.4 Contruir e iniciar os containers
```bash
docker compose build --no-cache
docker compose up
```



##### Abra no navegador
```bash
http://localhost:3000
```

Parar os containers quando terminar

```bash
docker compose down
```
