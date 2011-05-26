class CreateAggregations < ActiveRecord::Migration
  def self.up
    create_table :aggregations do |t|
      t.string :name
      t.decimal :score, :precision => 6, :scale => 2
      t.integer :parent_id
      t.decimal :weightage, :precision => 5, :scale => 2
      t.integer :drop_lowest
      t.boolean :weighted_average, :default => false
      t.integer :user_id
      t.timestamps
      
      t.foreign_key :user_id, :users, :id
    end
  end

  def self.down
    drop_table :aggregations
  end
end
