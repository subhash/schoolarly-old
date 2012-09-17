class UpgradeVideos < ActiveRecord::Migration
  def self.up
    add_column :videos, :token, :text
    change_column :videos, :description, :text
  end

  def self.down
    remove_column :videos, :token
    change_column :videos, :description, :string
  end

end
