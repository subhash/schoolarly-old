class Group < ActiveRecord::Base
  
  # Add new validates_uniqueness_of with correct scope
  validates_uniqueness_of :name, :scope => 'parent_id', :case_sensitive => false
  
  belongs_to :network, :polymorphic => true
  #include all members, pending members etc
  has_many :users, :through => :memberships do
    def of_type(type)
      find :all, :conditions => ['users.person_type = ?', type]
    end
  end
  has_many :student_users, :through => :memberships, :source => :user,
                        :conditions => ['users.person_type = ?', 'Student']
  has_many :teacher_users, :through => :memberships, :source => :user,
                        :conditions => ['users.person_type = ?', 'Teacher']                        
  acts_as_tree :order => 'name'
  named_scope :base, :conditions => {:parent_id => nil}
  named_scope :school, :conditions => {:network_type => 'School'}
  named_scope :klass, :conditions => {:network_type => 'Klass'}
  named_scope :subject, :conditions => {:network_type => 'Subject'}
  named_scope :default, :conditions => {:network_type => nil }
  
  def invite_and_accept(user)
    invite(user)
    accept_invitation(user)
  end
  
  def type
    network_type ? network_type.downcase.pluralize : 'groups'
  end
  
  def school?
    network_type == 'School'
  end 
  
  def klass?
    network_type == 'Klass'
  end 
  
  def applicable_members(type)
    case network_type
      when 'School'
      User.of_type(type) - Group.school.collect(&:users).flatten
      when 'Klass'
        case type
          when 'Student'
            parent.student_users - (parent.children.klass.collect(&:student_users)).flatten
          else
            parent.users.of_type(type) - users.of_type(type)
        end     
     else
        parent ? (parent.users.of_type(type) - users.of_type(type)) : (User.of_type(type) - users.of_type(type))
    end
  end

end
