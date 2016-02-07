class CreateNames < ActiveRecord::Migration
  def change
    create_table :names do |t|
      t.integer :id
      t.string :name

      t.timestamps null: true
    end
  end
end
