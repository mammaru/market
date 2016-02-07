class CreatePrices < ActiveRecord::Migration
  def change
    create_table :prices do |t|
      t.integer :name_id
      t.integer :date_id
      t.float :start
      t.float :end
      t.float :high
      t.float :low

      t.timestamps null: true
    end
  end
end
