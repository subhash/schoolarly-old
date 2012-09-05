class Group < ActiveRecord::Base
  
  # Add new validates_uniqueness_of with correct scope
  validates_uniqueness_of :name, :scope => [:parent_id], :case_sensitive => false
  
  belongs_to :network, :polymorphic => true
  #include all members, pending members etc
  has_many :users, :through => :memberships, :include => :profile, :order => "profiles.first_name, profiles.last_name" do
    def of_type(type)
      find :all, :conditions => ['users.person_type = ?', type]
    end
    
    def of_types(types)
      find :all, :conditions => ['users.person_type in (?)', types]
    end
  end
  
  has_many :student_users, :through => :memberships, :source => :user,
  :conditions => ['users.person_type = ?', 'Student'], :include => :profile, :order => "profiles.first_name, profiles.last_name"
  has_many :teacher_users, :through => :memberships, :source => :user,
  :conditions => ['users.person_type = ?', 'Teacher'], :include => :profile, :order => "profiles.first_name, profiles.last_name"
  
  acts_as_tree :order => 'name', :dependent => :destroy
  
  
  has_many :active_children, :class_name => 'Group', :foreign_key => 'parent_id', :order => 'name',
                                   :conditions => ['groups.state = ?', 'active']
  
  named_scope :base, :conditions => {:parent_id => nil}
  named_scope :school, :conditions => {:network_type => 'School'}
  named_scope :klass, :conditions => {:network_type => 'Klass'}
  named_scope :subject, :conditions => {:network_type => 'Subject'}
  named_scope :default, :conditions => {:network_type => nil }
  aasm_state :archived, :enter => :do_archive
  aasm_event :archive do
    transitions :from => :active, :to => :archived
  end
  
  has_many :sharings, :class_name => 'Share', :dependent => :destroy, :as => :shared_to, :order => "updated_at desc"  do
    def of_type(type)
      find :all, :conditions => {:shareable_type => type}
    end
  end
  
  def invite(user)
    parent.invite(user) if (parent and !parent.membership_of(user))
    mem = membership_of(user)
    mem = self.memberships.build(:user => user) unless mem
    mem.save!
    mem.invite!
  end
  
  def parent_users
    users.collect(&:profile).collect(&:friends).flatten.collect(&:user)
  end
  
  def parent_user_ids
    users.collect(&:profile).collect(&:friends).flatten.collect(&:user_id)
  end
  
  def display_name
    subject? ? name+" ["+parent.name+"]" : name
  end
  
  
  def active?
    self.state == 'active'
  end
  
  def accept_invitation(user)
    parent.accept_invitation(user) if (parent and parent.membership_of(user).invited?)
    mem = membership_of(user)
    mem.accept_invitation! if mem && mem.invited?
  end
  
  def join(user,moderator=false)
    parent.join(user) if (parent and !parent.membership_of(user))
    
    # todo Confirm what to do if th user is already a member. By now just ignore it and continue.
    mem = membership_of(user)
    mem = self.memberships.build(:user => user, :moderator => moderator) unless mem
    mem.save!
    grant_moderator(user) if moderator
    mem.activate! unless self.moderated?
  end
  
  def leave(user)
    # TODO Check if last member or moderator of child group
    for child in children
      child.leave(user) if child.membership_of(user) && child.active?
    end
    mem = membership_of(user)
    mem.destroy if mem
  end
  
  def invite_and_accept(user)
    invite(user)
    accept_invitation(user)
  end
  
  def type
    network_type ? network_type.downcase.pluralize : 'groups'
  end
  
  def general?
    network_type.blank?
  end
  
  def school?
    network_type == 'School'
  end
  
  def klass?
    network_type == 'Klass'
  end
  
  def subject?
    network_type == 'Subject'
  end
  
  def applicable_members(type, for_user=nil)
    if for_user
      school_groups = for_user.groups.school
      g_ids = []
      for school_group in school_groups
        g_ids += school_group.self_and_descendents.select{|g|g.moderators.include?(for_user)}.collect(&:id)
      end
      User.of_type(type).of_groups(g_ids) - self.users.of_type(type)
    else
      case network_type
        when 'School'
        if type == 'Parent'
          self.student_users.collect(&:friend_users).flatten.uniq
        else
          User.of_type(type) - Group.school.collect(&:users).flatten
        end
        when 'Klass'
        case type
          when 'Student'
          parent.student_users - (parent.active_children.klass.collect(&:student_users)).flatten
        else
          parent.users.of_type(type) - users.of_type(type)
        end
        when 'Subject'
        if  type == 'Teacher' && parent.klass?
          parent.parent.teacher_users - teacher_users
        else
          parent ? (parent.users.of_type(type) - users.of_type(type)) : (User.of_type(type) - users.of_type(type))
        end
      else
        if parent
          parent.users.of_type(type) - users.of_type(type)
        else
          []
        end
      end
    end
  end
  
  def removable_members(type)
    users.of_type(type)
  end
  
  def moderator_candidates
   (self.general? ? self.users : self.users.of_type('Teacher')) - self.moderators
  end
  
  def set_default_image
    unless self.image?
      Dir.glob(RAILS_ROOT + "/public/images/#{name}.*") do |filename|
        self.image = File.new(filename)
        return
      end
      if Tog::Config["plugins.tog_social.group.image.default"]
        default_group_image = File.join(RAILS_ROOT, 'public', 'tog_social', 'images', Tog::Config["plugins.tog_social.group.image.default"])
        self.image = File.new(default_group_image)
      end
    end
  end
  
  def memberships_of(users)
    users.collect {|u| membership_of(u)}.delete_if {|m| m.nil?}
  end
  
  def path
    s = []
    ancestors.reverse.each{|a| s << a.name + " > "}
    s.join+name
  end
  
  
  #  def update_default_notebooks
  #    old_name = name_was
  #    new_name = name
  #    unless leaf?
  #      for child in children
  #        child.update_child_notebooks(old_name, new_name)
  #      end
  #    end 
  #    s = []
  #    ancestors.reverse.each{|a| s << a.name + " > "}
  #    s = s.join+name_was 
  #    for user in  users
  #      b = user.blogs.find_by_description(Tog::Config["plugins.schoolarly.group.notebook.default"]+" "+s)
  #      b.update_attributes(:title => self.display_name, :description => (Tog::Config["plugins.schoolarly.group.notebook.default"]+" "+self.path)) if b
  #    end
  #  end
  #  
  #  def update_child_notebooks(old_name, new_name)
  #    new_path = self.path.sub(old_name,new_name)
  #    new_title = self.display_name.sub(old_name, new_name)
  #    unless leaf?
  #      for child in children
  #        child.update_child_notebooks(old_name, new_name)
  #      end
  #    end 
  #    for user in  users
  #      b = user.default_notebook_for(self)
  #      b.update_attributes(:title => new_title, :description => (Tog::Config["plugins.schoolarly.group.notebook.default"]+" "+new_path)) if b
  #    end
  #  end
  
  
  def school
    self.school? ? self.network : (self.parent ? parent.school : nil)
  end
  
  def do_archive
    unless leaf?
      for child in active_children
        child.archive!
      end
    end
  end
  
  def last_moderator?(user)
    return true if moderators.include?(user) && moderators.size == 1
    for child in children
      return true if child.last_moderator?(user)
    end
    return false
  end
end
