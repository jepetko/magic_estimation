class User < ActiveRecord::Base

  before_save :set_default_role

  has_secure_password validations: false
  validates :name, presence: true, uniqueness: true
  validates :password, presence: true, on: :create

  has_many :estimations
  has_many :items, through: :estimations

  scope :members, -> { where(role: 'member')}

  def admin?
    self.role == 'admin'
  end

  def member?
    self.role == 'member'
  end

  private

  def set_default_role
    self.role ||= 'member'
  end
end