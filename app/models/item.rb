class Item < ActiveRecord::Base

  attr_accessor :the_initial_estimator

  validates :name, :description, :creator, presence: true
  belongs_to :backlog
  belongs_to :creator, foreign_key: 'user_id', class_name: 'User'
  has_many :estimations
  has_many :estimators, through: :estimations

  scope :for_backlog, ->(backlog) {
    where(backlog: backlog).joins('LEFT JOIN estimations ON estimations.item_id = items.id').distinct
  }
  scope :for_backlog_already_estimated, ->(backlog) {
    for_backlog(backlog).where.not(:'estimations.value' => nil)
  }
  scope :for_backlog_not_estimated_yet, ->(backlog) {
    for_backlog(backlog).where(:'estimations.value' => nil)
  }


  scope :for_backlog_and_estimator_to_be_estimated_initially, ->(backlog,estimator) {
    for_backlog_not_estimated_yet(backlog).where(:'estimations.initial' => true, :'estimations.user_id' => estimator.id)
  }
  scope :for_backlog_and_estimator_already_estimated, ->(backlog,estimator) {
    for_backlog_already_estimated(backlog).where(:'estimations.user_id' => estimator.id)
  }
  scope :for_backlog_and_estimator_not_estimated_yet, ->(backlog,estimator) {
    already_estimated = for_backlog_and_estimator_already_estimated(backlog,estimator).collect &:id
    for_backlog(backlog).where.not(:id => already_estimated)
  }


  scope :for_backlog_and_another_estimator, ->(backlog,estimator) {
    where(backlog: backlog).joins(:estimations).where("estimations.user_id != #{estimator.id}")
  }
  scope :for_backlog_and_another_estimator_already_estimated_initially, ->(backlog,estimator) {
    for_backlog_and_another_estimator(backlog,estimator).where.not(:'estimations.value' => nil).where(:'estimations.initial' => true)
  }
  scope :for_backlog_and_estimator_to_be_estimated_next, ->(backlog,estimator) {
    already_estimated_as_next = where(backlog: backlog).joins(:estimations).where(:'estimations.user_id' => estimator.id).where(:'estimations.initial' => false).where.not(:'estimations.value'=> nil).collect(&:id)
    for_backlog_and_another_estimator_already_estimated_initially(backlog,estimator).where.not(:'estimations.item_id' => already_estimated_as_next)
  }

  def initial_estimator
    # note: there should be only one estimator with initial = true for an item!
    self.the_initial_estimator ||= self.estimators.where('estimations.initial' => true).first
  end

  def self.any_to_be_estimated_initially?(backlog,user,&block)
    size = Item.for_backlog_and_estimator_to_be_estimated_initially(backlog,user).size
    if block_given?
      block.call(size)
    end
    size > 0
  end

  def self.any_to_be_estimated_next?(backlog,user,&block)
    size = Item.for_backlog_and_estimator_to_be_estimated_next(backlog,user).size
    if block_given?
      block.call(size)
    end
    size > 0
  end

  def self.any_estimated?(backlog, user,&block)
    size = Item.for_backlog_and_estimator_already_estimated(backlog,user).size
    if block_given?
      block.call(size)
    end
    size > 0
  end
end