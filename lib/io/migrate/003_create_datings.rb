class CreateDatings < ActiveRecord::Migration
  def change
    create_table :datings do |t|
      t.date :date
      t.timestamps null: false
    end
  end
end
