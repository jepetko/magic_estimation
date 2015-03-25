class Estimation < ActiveRecord::Base

  validates :user_id, presence: true
  validates :initial, inclusion: { in: [true,false] }

  belongs_to :item
  belongs_to :estimator, foreign_key: 'user_id', class_name: 'User'

  scope :total, ->(estimator) {where(user_id: estimator.id)}
  scope :initial, ->(estimator) { total(estimator).where(initial: true)}
  scope :initial_not_estimated_yet, ->(estimator) { initial(estimator).where(value: nil)}
  scope :initial_already_estimated, ->(estimator) { initial(estimator).where.not(value: nil)}

end