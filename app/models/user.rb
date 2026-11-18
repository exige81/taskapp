class User < ApplicationRecord
  # Users are managed from the Rails console (`kamal console`); there is no
  # public sign-up or email-based password reset.
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :tasks

  normalizes :email, with: ->(email) { email.strip.downcase }

  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, length: { minimum: 6 }, allow_nil: true
end
