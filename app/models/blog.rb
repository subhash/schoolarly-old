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
  def default_for_group?
    author.groups.each do |g|
      if title == g.path && description ==  Tog::Config["plugins.schoolarly.group.notebook.default"]
        return true
      end
    end
    return false
  end
end
