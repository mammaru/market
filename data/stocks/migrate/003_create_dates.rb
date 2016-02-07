class CreateDates < ActiveRecord::Migration
  def change
    create_table :dates do |t|
      t.integer :date_id
      t.datetime :date
    end
  end
end
