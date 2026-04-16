class TicketStatus < ApplicationRecord
  has_many :tickets
  has_many :ticket_status_histories

  validates :name, presence: true, uniqueness: true
  validates :is_default, inclusion: { in: [true, false] }
  validates :is_final, inclusion: { in: [true, false] }

  validate :only_one_default, if: :is_default?

  # Impede a exclusão se houver tickets associados
  before_destroy :check_for_dependent_records

  private

  def only_one_default
    existing = TicketStatus.where(is_default: true)
    existing = existing.where.not(id: id) if persisted?
    errors.add(:is_default, "já existe um status padrão") if existing.exists?
  end

  def check_for_dependent_records
    if tickets.exists?
      errors.add(:base, "Não é possível remover este status porque existem chamados vinculados a ele.")
      throw :abort
    end
  end
end