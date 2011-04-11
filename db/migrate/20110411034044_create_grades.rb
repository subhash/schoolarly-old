class CreateGrades < ActiveRecord::Migration
  def self.up
    create_table :grades do |t|
      
      t.integer :user_id
      t.integer :assignment_id
      t.decimal :score, :precision => 6, :scale => 2
      t.timestamps     
      t.foreign_key :user_id, :users, :id
      t.foreign_key :assignment_id, :assignments, :id     
    end
  end

  def self.down
    drop_table :grades
  end
end
