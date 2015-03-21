class CreateEstimations < ActiveRecord::Migration
  def change
    create_table :estimations do |t|
      t.integer :item_id
      t.integer :user_id
      t.boolean :initial
      t.integer :value
      t.timestamps
    end
  end
end
