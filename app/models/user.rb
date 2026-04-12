class User < ApplicationRecord
  has_secure_password

  enum :role, { admin: 0, collaborator: 1, resident: 2 }

  has_many :unit_residents, foreign_key: :user_id, dependent: :destroy
  has_many :units, through: :unit_residents
  has_many :tickets, foreign_key: :user_id
  has_many :comments, foreign_key: :user_id
  has_many :ticket_status_histories, foreign_key: :user_id

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true,
            format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :role, presence: true
end
