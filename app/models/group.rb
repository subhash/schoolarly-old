class Group < ActiveRecord::Base
  
  belongs_to :network, :polymorphic => true
  has_many :users, :through => :memberships #include all members, pending members etc
  has_many :student_users, :through => :memberships, :source => :user,
                        :conditions => ['users.person_type = ?', 'Student']
  
  acts_as_tree :order => 'name'
  has_many :sub_groups, :foreign_key => 'parent_id'
  named_scope :base, :conditions => {:parent_id => nil}
  named_scope :school, :conditions => {:network_type => 'School'}
  named_scope :klass, :conditions => {:network_type => 'Klass'}
  named_scope :default, :conditions => {:network_type => nil }
  
  def invite_and_accept(user)
    invite(user)
    accept_invitation(user)
  end
  
end
