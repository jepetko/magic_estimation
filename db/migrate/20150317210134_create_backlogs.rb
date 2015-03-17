class CreateBacklogs < ActiveRecord::Migration
  def change
    create_table :backlogs do |t|
      t.string :name
      t.text :description
      t.timestamps
    end
  end
end
