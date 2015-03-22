class Item < ActiveRecord::Base

  attr_accessor :the_initial_estimator

  validates :name, :description, :creator, presence: true
  belongs_to :backlog
  belongs_to :creator, foreign_key: 'user_id', class_name: 'User'
  has_many :estimations
  has_many :estimators, through: :estimations

  scope :for_backlog_and_estimator, ->(backlog,estimator) {
    where(backlog: backlog).joins('LEFT JOIN estimations ON estimations.item_id = items.id').where("estimations.user_id IS NULL OR estimations.user_id = #{estimator.id}")
  }
  scope :for_backlog_and_estimator_already_estimated, ->(backlog,estimator) {
    for_backlog_and_estimator(backlog,estimator).where.not(:'estimations.value' => nil)
  }
  scope :for_backlog_and_estimator_not_estimated_yet, ->(backlog,estimator) {
    for_backlog_and_estimator(backlog,estimator).where(:'estimations.value' => nil)
  }
  scope :for_backlog_and_estimator_to_be_estimated_initially, ->(backlog,estimator) {
    for_backlog_and_estimator_not_estimated_yet(backlog,estimator).where(:'estimations.initial' => true)
  }
  scope :for_backlog_and_estimator_to_be_estimated_next, ->(backlog,estimator) {
    for_backlog_and_estimator_not_estimated_yet(backlog,estimator).where("estimations.initial IS NULL OR estimations.initial = 'f'")
  }

  def initial_estimator
    # note: there should be only one estimator with initial = true for an item!
    self.the_initial_estimator ||= self.estimators.where('estimations.initial' => true).first
  end

  def self.any_to_be_estimated_initially?(backlog,user)
    Item.for_backlog_and_estimator_to_be_estimated_initially(backlog,user).size > 0
  end

  def self.any_to_be_estimated_next?(backlog,user)
    Item.for_backlog_and_estimator_to_be_estimated_next(backlog,user).size > 0
  end

  def self.any_estimated?(backlog, user)
    Item.for_backlog_and_estimator_already_estimated(backlog,user).size > 0
  end
end