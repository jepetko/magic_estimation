class Estimation < ActiveRecord::Base
  before_create :set_initial

  belongs_to :item
  belongs_to :estimator, foreign_key: 'user_id', class_name: 'User'

  private
  def set_initial
    self.initial = true
  end
end