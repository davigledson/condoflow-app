# app/models/block.rb
class Block < ApplicationRecord
  has_many :units, dependent: :destroy

  validates :identifier, presence: true, uniqueness: true
  validates :floors_count, presence: true, numericality: { greater_than: 0 }
  validates :units_per_floor, presence: true, numericality: { greater_than: 0 }

  after_create :generate_units

  before_destroy :check_for_tickets, prepend: true

  private

  def generate_units
    (1..floors_count).each do |floor|
      (1..units_per_floor).each do |num|
        units.create!(
          floor_number: floor,
          unit_number: num,
          identifier: "#{identifier}-#{floor.to_s.rjust(2, '0')}-#{num.to_s.rjust(2, '0')}"
        )
      end
    end
  end

  def check_for_tickets
    if units.joins(:tickets).exists?
      errors.add(:base, "Não é possível remover o bloco porque existem chamados associados a suas unidades.")
      throw :abort
    end
  end
end