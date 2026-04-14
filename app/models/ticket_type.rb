class TicketType < ApplicationRecord
  has_many :tickets

  has_many :collaborator_ticket_types, dependent: :destroy
  has_many :collaborators, through: :collaborator_ticket_types, source: :user

  validates :title, presence: true, uniqueness: true
  validates :sla_hours, presence: true, numericality: { greater_than: 0 }
end
