class Point < ActiveRecord::Base
  validates :value, presence: true
end