# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :timeoutable, :trackable, :recoverable and :omniauthable
  # :recoverable is omitted (no email provider) and public sign-up is disabled
  # in routes; create users and reset passwords via the Rails console.
  devise :database_authenticatable, :registerable,
         :rememberable, :validatable, :lockable

  has_many :tasks
end
