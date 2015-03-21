class AddCreatorToBacklogs < ActiveRecord::Migration
  def change
    add_column :backlogs, :user_id, :integer
  end
end
