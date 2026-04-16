# CondoFlow - Guia de Comandos Rails

## Setup inicial

```bash
bundle install
rails db:create
rails db:migrate
rails db:seed
```

---

## Rodar o projeto

```bash

rails server
```

---

##  Banco de Dados

```bash
rails db:create        # cria o banco
rails db:drop          # deleta o banco
rails db:migrate       # roda migrations
rails db:rollback      # desfaz última migration
rails db:reset         # drop + create + migrate + seed
rails db:seed          # popula dados iniciais
```

---

## Gerar estruturas

### Model

```bash
rails generate model Nome campo:tipo

rails generate model Nome --no-migration
```

### Controller

```bash
rails generate controller Nome index show new create
```

### Migration

```bash
rails generate migration NomeDaMigration
```

### Scaffold (tudo automático)

```bash
rails generate scaffold Nome campo:tipo
```

---

## Console Rails

```bash
rails console
```

---

## Rotas

```bash
rails routes
```

---

## Tailwind

```bash
rails tailwindcss:install
rails tailwindcss:build
bin/dev
```

---

## Limpeza / Cache

```bash
rails tmp:clear
rails assets:clobber
```

---

## Logs

```bash
tail -f log/development.log
```

---

## Credenciais

```bash
rails credentials:edit
rails secret #gerar chave nova
```

---


## Fluxo comum de desenvolvimento

```bash
rails generate model
rails db:migrate
rails generate controller
bin/dev
```

---

## Status do projeto

* Rails 8
* PostgreSQL
* TailwindCSS
* Propshaft
