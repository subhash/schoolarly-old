class RebuildGroup < ActiveRecord::Migration
  def self.up
    Group.rebuild!
  end

  def self.down
  end
end
