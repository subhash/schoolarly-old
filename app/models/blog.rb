# == Schema Information
# Schema version: 1
#
# Table name: blogs
#
#  id           :integer(11)   not null, primary key
#  title        :string(255)
#  description  :text
#  user_id      :integer(11)
#  created_at   :datetime
#  updated_at   :datetime
#
class Blog < ActiveRecord::Base
  
  acts_as_textiled :description
  acts_as_sanitized
  
  def default_for_group?
    Group.all.each do |g|
      if self.description(:source) == Tog::Config["plugins.schoolarly.group.notebook.default"]+ " "+g.path
        return true
      end
    end
    return false
  end
  
    def default_notebook?
    User.all.each do |u|
      if self.description(:source) == "Default notebook for "+u.email && self.title == "Default Notebook"
        return true
      end
    end
    return false
  end
end
