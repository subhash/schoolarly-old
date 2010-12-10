class UpgradeTogConclave20101210125523 < ActiveRecord::Migration
  def self.up
    
      migrate_plugin "tog_conclave", 8
    
  end

  def self.down
    
      migrate_plugin "tog_conclave", 0
    
  end
end