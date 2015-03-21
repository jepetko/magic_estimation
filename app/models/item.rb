class Item < ActiveRecord::Base

  attr_accessor :the_initial_estimator

  validates :name, :description, :creator, presence: true
  belongs_to :backlog
  belongs_to :creator, foreign_key: 'user_id', class_name: 'User'
  has_many :estimations
  has_many :estimators, through: :estimations

  def initial_estimator
    # note: there should be only one estimator with initial = true for an item!
    self.the_initial_estimator ||= self.estimators.where('estimations.initial' => true).limit(1).first
  end
end