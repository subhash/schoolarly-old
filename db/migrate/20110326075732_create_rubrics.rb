class CreateRubrics < ActiveRecord::Migration
  def self.up
    create_table :rubrics do |t|
      
      t.string :title

      t.timestamps
    end
  end

  def self.down
    drop_table :rubrics
  end
end
