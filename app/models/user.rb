class User < ApplicationRecord
  authenticates_with_sorcery! do |config|
    config.submodules = [:remember_me, :reset_password]
  end
      
  validates :name, presence: true
  validates :email, presence: true, uniqueness: true
  validates :password, length: { minimum: 6 }, if: -> { new_record? || changes[:crypted_password] }
  validates :password, confirmation: true, if: -> { new_record? || changes[:crypted_password] }
  validates :password_confirmation, presence: true, if: -> { new_record? || changes[:crypted_password] }
      
  has_many :posts, dependent: :destroy
  has_many :recommendations, dependent: :destroy
end
