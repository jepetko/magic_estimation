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


  scope :for_backlog_to_be_reestimated, ->(backlog) {
    estimations = Estimation.select('items.id').joins(:item).where(:'items.backlog_id' => backlog.id).group('estimations.item_id').having('count(estimations.id) >= 2').collect(&:id)
    where(backlog: backlog).where(id: estimations).order(id: :asc)
  }

  def assign_to_initial_estimator(user_id)
    user_id = user_id.id if user_id.instance_of?(User)
    estimation = Estimation.where.not(user_id: user_id, value: nil).where(item: self, initial: true).first
    if !estimation.nil?
      raise "This item cannot be re-assigned because its already estimated initially with #{estimation.value} points."
    else
      begin
        ActiveRecord::Base.transaction do
          estimation = Estimation.find_by(user_id: user_id, item: self) || Estimation.new(user_id: user_id, item: self)
          estimation.initial = true
          if !estimation.save
            raise estimation.errors.full_messages.join(', ')
          end
          # set initial = false for the previous assignees
          Estimation.where.not(user_id: user_id).where(item: self).update_all(initial: false)
        end
      rescue Exception => e
        raise e.message
      end
    end
    estimation
  end

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

  def self.any_to_be_possibly_reestimated?(backlog,&block)
    size = Item.for_backlog_to_be_reestimated(backlog).size
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