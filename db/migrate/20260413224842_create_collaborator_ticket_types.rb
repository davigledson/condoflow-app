# db/migrate/20260413000001_create_collaborator_ticket_types.rb
class CreateCollaboratorTicketTypes < ActiveRecord::Migration[8.1]
  def change
    create_table :collaborator_ticket_types do |t|
      t.references :user, null: false, foreign_key: true
      t.references :ticket_type, null: false, foreign_key: true
      t.timestamps
    end

    add_index :collaborator_ticket_types, [:user_id, :ticket_type_id], unique: true
  end
end