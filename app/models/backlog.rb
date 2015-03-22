class Backlog < ActiveRecord::Base

  validates :name, :description, :creator, presence: true
  has_many :items, dependent: :destroy
  belongs_to :creator, foreign_key: 'user_id', class_name: 'User'
  has_many :estimations, through: :items
  has_many :estimators, through: :estimations, source: :estimator

  scope :backlogs_with_items_for_estimator, ->(estimator) { joins(:items).joins(:estimations).where(estimations: { user_id: estimator.id }).distinct }
  scope :backlogs_with_items_for_estimator_where_initial, ->(estimator,initial) { backlogs_with_items_for_estimator(estimator).where(:'estimations.initial' => initial) }

  scope :backlogs_with_items_for_estimator_to_be_estimated_initially, ->(estimator) { backlogs_with_items_for_estimator_where_initial(estimator,true) }
  scope :backlogs_with_items_for_estimator_to_be_estimated_initially_not_estimated_yet, ->(estimator) {
    backlogs_with_items_for_estimator_to_be_estimated_initially(estimator).where(:'estimations.value' => nil)
  }
  scope :backlogs_with_items_for_estimator_to_be_estimated_as_next, ->(estimator) { backlogs_with_items_for_estimator_where_initial(estimator,false) }
  scope :backlogs_with_items_for_estimator_to_be_estimated_as_next_not_estimated_yet, ->(estimator) {
    backlogs_with_items_for_estimator_to_be_estimated_as_next(estimator).where('estimations.value' => nil)
  }

  def any_to_be_estimated_initially?(user)
    Backlog.backlogs_with_items_for_estimator_to_be_estimated_initially_not_estimated_yet(user).size > 0
  end

  def any_to_be_estimated_next?(user)
    Backlog.backlogs_with_items_for_estimator_to_be_estimated_as_next_not_estimated_yet(user).size > 0
  end
end