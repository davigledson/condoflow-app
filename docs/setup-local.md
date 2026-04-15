# Setup Local (Sem Docker)

Este guia explica como rodar o CondoFlow App diretamente na sua máquina.

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

Crie .env ou .env.development:

```bash
DB_USERNAME=condoflow
DB_PASSWORD=condoflow
DB_HOST=localhost

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