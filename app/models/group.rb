class Group < ActiveRecord::Base

  has_many :users, :through => :memberships #include all members, pending members etc
  acts_as_tree :order => 'name'
  named_scope :base, :conditions => {:parent_id => nil}
end
