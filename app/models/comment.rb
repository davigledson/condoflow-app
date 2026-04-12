# app/models/comment.rb
class Comment < ApplicationRecord
  belongs_to :ticket
  belongs_to :user

  validates :body, presence: true

  validate :user_can_comment

  private

  def user_can_comment
    return unless user && ticket

    if user.resident?
      # Morador só comenta nos chamados das suas unidades
      allowed_tickets = Ticket.where(unit: user.units)
      unless allowed_tickets.include?(ticket)
        errors.add(:user, "não tem permissão para comentar neste chamado")
      end
    end
    # admin e collaborator podem comentar em qualquer chamado
    # (escopo de acesso do collaborator é tratado no controller)
  end
end