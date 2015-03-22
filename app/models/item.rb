class Item < ActiveRecord::Base

  validates :name, :description, :creator, presence: true
  belongs_to :backlog
  belongs_to :creator, foreign_key: 'user_id', class_name: 'User'
  has_many :estimations
  has_many :estimators, through: :estimations

  scope :for_backlog, ->(backlog) { where(backlog: backlog) }
  scope :for_backlog_and_estimator_where_initial, ->(backlog,estimator,initial) { where(backlog: backlog).joins(:estimations).where(user_id: estimator.id,:'estimations.initial' => initial) }

  def initial_estimator
    # note: there should be only one estimator with initial = true for an item!
    self.estimators.where('estimations.initial' => true).first
  end

end