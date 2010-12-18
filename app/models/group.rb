class Group < ActiveRecord::Base

  acts_as_tree :order => 'name'
  named_scope :base, :conditions => {:parent_id => nil}
end
