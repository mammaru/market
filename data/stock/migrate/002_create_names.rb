class CreateNames < ActiveRecord::Migration
  def change
    create_table :names, {id: false, primary_key: :code} do |t|
      t.integer :code
      t.string :name
      t.timestamps
    end
  end
end
