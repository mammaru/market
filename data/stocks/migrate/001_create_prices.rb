class CreatePrices < ActiveRecord::Migration
  def change
    create_table :prices do |t|
      t.integer :code
      t.integer :dating_id
      t.integer :open
      t.integer :high
      t.integer :low
      t.integer :close
      t.float :volume
      t.timestamps
    end
  end
end
