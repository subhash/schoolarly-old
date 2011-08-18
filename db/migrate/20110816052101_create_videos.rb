class CreateVideos < ActiveRecord::Migration
  def self.up
    create_table :videos do |t|
      t.string :title
      t.string :description
      t.string :link
      t.integer :user_id
      t.timestamps
    end
  end

  def self.down
    drop_table :videos
  end
end
