class UpgradeTogConversatio20101210142251 < ActiveRecord::Migration
  def self.up
    
      migrate_plugin "tog_conversatio", 5
    
  end

  def self.down
    
      migrate_plugin "tog_conversatio", 0
    
  end
end