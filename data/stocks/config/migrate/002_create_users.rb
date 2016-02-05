class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :name
      t.integer :tweet_count

      t.timestamps null: true
    end
  end
end
