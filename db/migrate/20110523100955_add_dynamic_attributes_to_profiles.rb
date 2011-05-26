class AddDynamicAttributesToProfiles < ActiveRecord::Migration
  def self.up
    add_column :profiles, :dynamic_attributes, :text
  end

  def self.down
    remove_column :dynamic_models, :dynamic_attributes
  end
end
