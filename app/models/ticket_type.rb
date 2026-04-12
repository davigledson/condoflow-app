class TicketType < ApplicationRecord
  has_many :tickets

  validates :title, presence: true, uniqueness: true
  validates :sla_hours, presence: true, numericality: { greater_than: 0 }
end
