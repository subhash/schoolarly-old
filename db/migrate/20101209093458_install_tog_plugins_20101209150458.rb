class InstallTogPlugins20101209150458 < ActiveRecord::Migration
  def self.up
    
      migrate_plugin "tog_user", 1
    
      migrate_plugin "tog_core", 7
    
      migrate_plugin "tog_social", 6
    
      migrate_plugin "tog_mail", 2
    
  end

  def self.down
    
      migrate_plugin "tog_mail", 0
    
      migrate_plugin "tog_social", 0
    
      migrate_plugin "tog_core", 0
    
      migrate_plugin "tog_user", 0
    
  end
end