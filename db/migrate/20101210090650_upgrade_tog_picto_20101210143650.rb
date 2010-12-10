class UpgradeTogPicto20101210143650 < ActiveRecord::Migration
  def self.up
    
      migrate_plugin "tog_picto", 7
    
  end

  def self.down
    
      migrate_plugin "tog_picto", 0
    
  end
end