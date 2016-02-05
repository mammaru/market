class CreateAutonomies < ActiveRecord::Migration
  def change
    create_table :autonomies do |t|
      t.string :name
      t.integer :tweet_count
    end
  end
end
