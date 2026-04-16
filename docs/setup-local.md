# Setup Local (Sem Docker)

Este guia explica como rodar a aplicação diretamente na sua máquina.

---

# Requisitos

Antes de começar, instale:

- Ruby 3.2+
- Rails 8.1.3
- Bundler
- PostgreSQL 13+
- ImageMagick (para processamento de imagens)

---

# 1. Clonar o projeto

```bash
git clone https://github.com/davigledson/condoflow-app.git
cd condoflow-app
```

# 2. Instalar dependências Ruby

```bash
bundle install
```

# 3. Configurar credentials (Rails)

```bash
rails credentials:edit
```
Isso cria:

config/master.key
config/credentials.yml.enc

# 4. Configurar variáveis de ambiente

Crie um .env:

```bash
#geralmente e postgres mesmo
DB_USERNAME=username_do_postgres

DB_PASSWORD=senha
DB_HOST=localhost
DB_PORT=5432

RAILS_MASTER_KEY=sua_master_key
```
# 5. Preparar banco de dados

```bash
rails db:create
rails db:migrate
rails db:seed
```
# 6. Rodar o projeto

```bash
rails server
```

#### acesse:

```bash
http://localhost:3000
```