class Estimation < ActiveRecord::Base
  before_create :set_initial

  belongs_to :item
  belongs_to :estimator, foreign_key: 'user_id', class_name: 'User'

  scope :total_for_estimator, ->(estimator) {where(user_id: estimator.id)}
  scope :initial_for_estimator, ->(estimator) { total_for_estimator(estimator).where(initial: true)}
  scope :initial_for_estimator_not_estimated_yet, ->(estimator) { initial_for_estimator(estimator).where(value: nil)}
  scope :initial_for_estimator_already_estimated, ->(estimator) { initial_for_estimator(estimator).where('value NOT NULL')}

  private
  def set_initial
    self.initial = true
  end
end