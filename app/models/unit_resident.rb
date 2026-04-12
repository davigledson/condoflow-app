class UnitResident < ApplicationRecord
  belongs_to :unit
  belongs_to :user

  validates :unit_id, uniqueness: { scope: :user_id }

  validate :user_must_be_resident

  private

  def user_must_be_resident
    errors.add(:user, "deve ter o papel de morador") unless user&.resident?
  end
end