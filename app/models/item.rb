class Item < ActiveRecord::Base
  validates :name, :description, :creator, presence: true
  belongs_to :backlog
  belongs_to :creator, foreign_key: 'user_id', class_name: 'User'
  has_many :estimations
  has_many :estimators, through: :estimations
end