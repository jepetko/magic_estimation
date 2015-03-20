class CreateItems < ActiveRecord::Migration
  def change
    create_table :items do |t|
      t.string :name
      t.text :description
      t.integer :type_id
      t.integer :backlog_id
      t.timestamps
    end
  end
end
