class TicketStatusHistory < ApplicationRecord
  belongs_to :ticket
  belongs_to :ticket_status
  belongs_to :user  # quem fez a alteração

  validates :ticket_id, :ticket_status_id, :user_id, presence: true
end