class InitialSchema < ActiveRecord::Migration[8.1]
  def change

    create_table :users do |t|
      t.string :email, null: false
      t.string :password_digest, null: false
      t.string :name, null: false
      t.integer :role, null: false, default: 2  # 0: admin, 1: collaborator, 2: resident
      t.timestamps
    end
    add_index :users, :email, unique: true

    #blocos - Um bloco tem muitas unidades (units)
    # Um bloco tem muitas unidades (units)
    create_table :blocks do |t|
      t.string :identifier, null: false
      t.integer :floors_count, null: false
      t.integer :units_per_floor, null: false
      t.timestamps
    end
    add_index :blocks, :identifier, unique: true

    #unidades
    #  Pertence a um bloco (blocks)
    #  Tem vários moradores (N:N via unit_residents)
    #  Pode ter vários chamados (tickets)
    #  
    # O identifier é gerado automaticamente ao criar o bloco (ex: "A-02-03" = Bloco A, andar 2, apto 3)
    #            .
    create_table :units do |t|
      t.references :block, null: false, foreign_key: true
      t.integer :floor_number, null: false
      t.integer :unit_number, null: false
      t.string :identifier, null: false  # ex: A-02-03
      t.timestamps
    end
    add_index :units, [:block_id, :floor_number, :unit_number],
              unique: true, name: "idx_units_block_floor_unit"

    #Vinculação morador-unidade (N:N)
    # - pertence a um unidade
    # - pertence a um morador
    create_table :unit_residents do |t|
      t.references :unit, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.timestamps
    end
    add_index :unit_residents, [:unit_id, :user_id], unique: true

    # Tipos de chamado
    create_table :ticket_types do |t|
      t.string :title, null: false
      t.integer :sla_hours, null: false #prazo padrão para resolução de conflitos
      t.timestamps
    end

    #Status de chamado
    # Um status pode estar em vários chamados (tickets)
    # Um status pode estar em várias entradas de histórico (ticket_status_histories)
    create_table :ticket_statuses do |t|
      t.string :name, null: false
      t.boolean :is_default, null: false, default: false
      t.boolean :is_final, null: false, default: false
      t.timestamps
    end

    #chamados
    ##   - Pertence a uma unit (unidade onde ocorre o problema)
    #   - Pertence a um user (morador que abriu o chamado)
    #   - Pertence a um ticket_type
    #   - Pertence a um ticket_status (status atual)
    #   - Tem vários comentários (comments)
    #   - Tem várias entradas de histórico (ticket_status_histories)
    create_table :tickets do |t|
      t.references :unit, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.references :ticket_type, null: false, foreign_key: true
      t.references :ticket_status, null: false, foreign_key: true
      t.text :description, null: false
      t.datetime :closed_at
      t.timestamps
    end

    # Comentários
    #   - Pertence a um ticket
    #   - Pertence a um user (autor do comentário)
    create_table :comments do |t|
      t.references :ticket, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.text :body, null: false
      t.timestamps
    end

    # Histórico de status (auditoria)
    create_table :ticket_status_histories do |t|
      t.references :ticket, null: false, foreign_key: true
      t.references :ticket_status, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.timestamps
    end

  end
end