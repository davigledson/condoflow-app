class TicketStatus < ApplicationRecord
    has_many :tickets
  has_many :ticket_status_histories

  validates :name, presence: true, uniqueness: true
  validates :is_default, inclusion: { in: [true, false] }
  validates :is_final, inclusion: { in: [true, false] }

  # Garante que só exista um status padrão no sistema
  validate :only_one_default, if: :is_default?

  private

  def only_one_default
    existing = TicketStatus.where(is_default: true)
    existing = existing.where.not(id: id) if persisted?
    errors.add(:is_default, "já existe um status padrão") if existing.exists?
  end
end
