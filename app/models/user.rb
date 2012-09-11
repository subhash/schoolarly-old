class User < ActiveRecord::Base

  belongs_to :person, :polymorphic => true

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
    profile.full_name
  end

  def school_moderator_for?(user)
    if self.admin?
    return true
    end
    school_groups = user.parent? ? user.person.school_groups : user.groups.school
    school_groups.collect(&:moderators).flatten.include?(self)
  end

  def messageable_user_ids
    if self.parent?
      users = self.person.school_groups.collect{|g| g.users.of_types("Teacher").map(&:id) + g.parent_user_ids}.flatten
      return (users + self.friend_user_ids + User.admin.map(&:id))
    elsif self.school
    return self.school.group.user_ids + (self.student? ? self.friend_user_ids : self.school.group.parent_user_ids)
    else
      return  self.groups.collect(&:user_ids).flatten

    end
  end

  def can_view?(user)
    return true if (self.admin? || !user.school)
    return ((self == user || !(self.groups & user.groups).empty?)) if !self.school
    if self.parent? && user.parent?
      return (self.friend_users.collect(&:school) & user.friend_users.collect(&:school)).empty?
    elsif self.parent?
      return self.friend_users.include?(user) || (!user.student? && self.friend_users.collect(&:school).include?(user.school))
    elsif user.parent?
      return user.friend_users.collect(&:school).include? (self.school)
    else
    return (self.school == user.school)
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
end
