class User < ActiveRecord::Base
  
  belongs_to :person, :polymorphic => true
  
  
  ### HORRIBLE HACK ## In order to preload shared_to.parent for shares in dashboard
  has_one :parent, :class_name  => 'Profile'
  
  named_scope :of_type, lambda { |type| {:conditions => {:person_type => type}}}
  
  named_scope :of_groups, lambda{ |group_ids|
    {
        :include      => :memberships,
        :conditions => {'memberships.group_id' => group_ids}
    }
  }
  
  has_many :attachments
  has_many :rubrics
  has_many :blogs, :through => :bloggerships, :include => :posts, :dependent => :destroy
  has_many :videos
  has_many :posts
  
  after_create :default_notebook
  def student?
    person.is_a? Student
  end
  
  def teacher?
    person.is_a? Teacher
  end
  
  def parent?
    person.is_a? Parent
  end
  
  def school
    valid_groups = parent? ? friend_users.first.groups : groups
    valid_groups.school.first.network unless valid_groups.school.blank?
  end
  
  def school_admin?
    school.group.moderators.include? self if school
  end
  
  def password_required?
    password_reset_code.blank? && (crypted_password.blank? || !password.blank?)
  end
  
  def invite_over_email(from = User.find_by_email(Tog::Config["plugins.tog_core.mail.system_from_address"]))
    self.password_reset_code = Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join )
    self.salt = self.class.make_token if new_record?
    @inviter = from
    save(true)
  end
  
  after_create :send_signup_invitation
  
  def send_signup_invitation
    UserMailer.deliver_signup_invitation_notification(self, @inviter) if @inviter
  end
  
  def send_activation_request
    # Prevent activation emails for invites
    UserMailer.deliver_signup_notification(self) unless self.activation_code.blank?
  end
  
  #  after_save :create_default_blog
  
  def type
    person_type ? person_type.downcase.pluralize : 'members'
  end
  
  def friend_users
    profile.friends.map(&:user)
  end
  
  def friend_user_ids
    profile.friends.map(&:user_id)
  end
  
  def name
    profile.name_or_email(self.email)
  end
  
  def school_moderator_for?(user)
    if self.admin?
      return true
    end
    school_groups = user.parent? ? user.person.school_groups : user.groups.school
    school_groups.collect(&:moderators).flatten.include?(self)
  end
  
  #  A parent can message any teacher or parent in his kids' schools + admin + his kids
  #  A student can message all students & teachers in his school (but not parents) + his parents
  #  A teacher can message all students, teachers and parents in his school
  #  A user not belonging to a school can message any member in his groups.
  
  def messageable_user_ids
    if self.admin?
      return User.all.collect(&:id)
    elsif self.parent?
      users = self.person.school_groups.collect{|g| g.users.of_types("Teacher").map(&:id) + g.parent_user_ids}.flatten
      return (users + self.friend_user_ids + User.admin.map(&:id))
    elsif self.school
      return self.school.group.user_ids + (self.student? ? self.friend_user_ids : self.school.group.parent_user_ids)
    else
      return  self.groups.collect(&:user_ids).flatten
    end
  end
  
  
  def can_view?(user)
    #    admin can view anyone. a user not belonging to any school can be viewed by anyone
    self.admin? || self == user || self.profile.is_friend_of?(user.profile) || !user.school || (self.school == user.school && self.teacher?)
  end
  
#  teachers can message anyone in school
#  students can message all teachers & students & their parents
#  parents can message all teachers & their wards

    def can_message?(user)
      can_view?(user) || (self.school == user.school && self.student? && !user.parent?) || (self.school == user.school && self.parent? && !user.student?)
  end
  
  
  
  def can_view_email?(group)
    if self.admin?
      return true
    elsif (self.school == group.school) 
      #  only teachers of a school can view emails in a school      
      return self.teacher?
      #      if i don't belong to any school, i can view emails in all groups moderated by me.
    elsif (self.groups.include?(group))
      return group.moderators.include?(self)
    end
  end
  
  def archive_notebook
    b = self.blogs.find_by_title_and_description("Archives", "Archive notebook")
    unless b
      bs = self.bloggerships.new
      bs.build_blog(:title => "Archives", :description => "Archive notebook", :author => self)
      bs.save
      b = bs.blog
    end
    return b
  end
  
  def default_notebook_for(group)
    #     same group names can be there under different parents. so not checking on title
    b = self.blogs.find_by_description(Tog::Config["plugins.schoolarly.group.notebook.default"]+" "+group.path)
    return b
  end
  
  def default_notebook
    #     same group names can be there under different parents. so not checking on title
    b = self.blogs.find_by_title_and_description("Default Notebook", "Default notebook for "+email)
    unless b
      bs = self.bloggerships.new
      bs.build_blog(:title => "Default Notebook", :description => "Default notebook for "+email, :author => self)
      bs.save
      b = bs.blog
    end
    return b
  end
  
  def self.site_search(query, search_options={})
    q = "#{query}%"
    if search_options[:user]
      User.find(:all, :include => :profile, :conditions => ["users.id IN (?) AND (profiles.first_name #{DATABASE_OPERATOR[:like_operator]} ? OR profiles.last_name #{DATABASE_OPERATOR[:like_operator]} ? OR users.login #{DATABASE_OPERATOR[:like_operator]} ?)", search_options[:user].messageable_user_ids, q, q, q]).flatten.paginate({:page => '1'})
    else
      User.find(:all, :include => :profile, :conditions => ["profiles.first_name #{DATABASE_OPERATOR[:like_operator]} ? OR profiles.last_name #{DATABASE_OPERATOR[:like_operator]} ? OR users.login #{DATABASE_OPERATOR[:like_operator]} ?",q, q, q]).flatten.paginate({:page => '1'})
    end
    
  end
  
  #  def create_default_blog
  #    if self.recently_activated?
  #      blog_name = "#{self.profile.full_name}'s blog"
  #      blog_description = "Default blog for #{self.profile.full_name}"
  #      unless self.bloggerships.find_by_rol("default")
  #        bs = self.bloggerships.new
  #        bs.rol = "default"
  #        bs.build_blog(:title => blog_name, :description => blog_description, :author => self)
  #        bs.save
  #      end
  #    end
  #  end
  
  #  def default_blog
  #    self.bloggerships.find_by_rol("default").blog
  #  end
  
  def self.move_blogs_to_default(*args)
    if args[0]
      users = User.find(args[0])
    else
      users = User.all
    end
    for user in users do
      puts "User - "+user.inspect
      default_note = user.default_notebook
      for post in user.posts do
        puts "Post - "+post.inspect
        post.blog = default_note
        post.save!
      end
      for blog in user.blogs
        unless blog.default_notebook?
          blog.destroy
        end
      end
      default_note.save!
    end
  end
  
  
  def self.from_csv(row)
    name, email, fname, femail, mname, memail, klassname = row
    user = User.new_or_existing(email, name, Student.new)
    father = User.new_or_existing(femail, fname, Parent.new)
    mother = User.new_or_existing(memail, mname, Parent.new)
    return [user, father, mother, klassname.blank? ? klassname : klassname.strip]
  end
  
  def self.new_or_existing(email, name, person)
    email = email.strip if email
    name = name.strip if name
    return nil if email.blank?
    user = self.find_by_email(email) || self.new(:email => email)
    user.login ||= user.email if Tog::Config["plugins.tog_user.email_as_login"]
    first = last = nil
    first, last = name.split(' ', 2) if name
    if user.profile
      user.profile.first_name = first.strip unless first.blank?
      user.profile.last_name = last.strip unless last.blank?
    else
      user.profile = Profile.new(:first_name => first,:last_name => last)
    end
    user.person ||= person
    return user  
  end
  
end
