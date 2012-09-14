class UpgradeVideos < ActiveRecord::Migration
  def self.up
    add_column :videos, :doc_file_name, :string
    add_column :videos, :doc_content_type, :string
    add_column :videos, :doc_file_size, :integer
    add_column :videos, :doc_updated_at, :datetime
    change_column :videos, :description, :text
  end

  def self.down
    remove_column :videos, :doc_file_name
    remove_column :videos, :doc_content_type
    remove_column :videos, :doc_file_size
    remove_column :videos, :doc_updated_at
    change_column :videos, :description, :string
  end

end
