class Backlog < ActiveRecord::Base

  validates :name, :description, :creator, presence: true
  has_many :items, dependent: :destroy
  belongs_to :creator, foreign_key: 'user_id', class_name: 'User'
end