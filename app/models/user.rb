class User < ActiveRecord::Base

  before_save :set_default_role

  has_secure_password
  validates :name, :password, presence: true

  has_many :estimations
  has_many :items, through: :estimations

  def admin?
    self.role == 'admin'
  end

  private

  def set_default_role
    self.role ||= 'member'
  end
end