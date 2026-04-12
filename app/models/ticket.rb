class Ticket < ApplicationRecord
  belongs_to :unit
  belongs_to :user  # morador que abriu
  belongs_to :ticket_type
  belongs_to :ticket_status

  has_many :comments, dependent: :destroy
  has_many :ticket_status_histories, dependent: :destroy

  validates :description, presence: true

  # Ao criar, força o status padrão
  before_validation :set_default_status, on: :create

  # Ao mudar para status final, registra closed_at
  before_save :set_closed_at, if: :ticket_status_id_changed?

  # Garante que o morador pertence à unidade do chamado
  validate :user_belongs_to_unit, on: :create

  private

  def set_default_status
    self.ticket_status ||= TicketStatus.find_by(is_default: true)
  end

  def set_closed_at
    if ticket_status&.is_final?
      self.closed_at = Time.current
    else
      self.closed_at = nil
    end
  end

  def user_belongs_to_unit
    return unless user && unit
    unless unit.residents.include?(user)
      errors.add(:user, "não pertence a essa unidade")
    end
  end
end