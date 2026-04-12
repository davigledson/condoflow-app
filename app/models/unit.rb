# app/models/unit.rb
class Unit < ApplicationRecord
  belongs_to :block

  has_many :unit_residents, dependent: :destroy
  has_many :residents, through: :unit_residents, source: :user
  has_many :tickets, dependent: :destroy

  validates :floor_number, presence: true, numericality: { greater_than: 0 }
  validates :unit_number, presence: true, numericality: { greater_than: 0 }
  validates :identifier, presence: true
  validates :unit_number, uniqueness: { scope: [:block_id, :floor_number] }
end