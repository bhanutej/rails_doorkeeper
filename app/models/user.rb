class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :lockable

  def admin?
    role.include?('admin')
  end

  # def active_for_authentication?
  #   super && self.status == 1 && self.deleted_at.blank?
  # end

  def self.authenticate(username, password)
    user = User.find_for_authentication(:email => username)

    password_valid = user.valid_password?(password) if user
    # active = user.active_for_authentication? if password_valid

    # To check user is locked or not. Need to call this whether password is wrong or right
    # Failed count will be increased in this method
    valid = user.valid_for_authentication?{ password_valid } if user

    # active && valid ? user : nil
    valid ? user : nil
  end
end
