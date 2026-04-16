# app/models/collaborator_ticket_type.rb
class CollaboratorTicketType < ApplicationRecord
  belongs_to :user
  belongs_to :ticket_type

  validates :ticket_type_id, uniqueness: { scope: :user_id }

  validate :user_must_be_collaborator

  private

  def user_must_be_collaborator
    errors.add(:user, "deve ser um colaborador") unless user&.collaborator?
  end
end