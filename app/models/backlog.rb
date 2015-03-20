class Backlog < ActiveRecord::Base

  validates :name, presence: true
  has_many :items, dependent: :destroy
end