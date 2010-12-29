class Group < ActiveRecord::Base
  
  belongs_to :network, :polymorphic => true
  has_many :users, :through => :memberships #include all members, pending members etc
  acts_as_tree :order => 'name'
  has_many :sub_groups, :foreign_key => 'parent_id'
  named_scope :base, :conditions => {:parent_id => nil}
  named_scope :of_network_type, lambda { |type| {:conditions => ['network_type = ?', type] } }
  
end
