class Assignment < ActiveRecord::Base 
  
  acts_as_shareable
  acts_as_commentable
  
  belongs_to :post, :dependent => :destroy
  
  has_many :shares_to_groups, :class_name => 'Share', :as => :shareable, :conditions => {:shared_to_type => 'Group'}
  
  accepts_nested_attributes_for :post
  
  
  belongs_to :rubric
  
  has_one :weighted_assignment
  
  validates_presence_of :start_time, :end_time, :if => :date
  
  before_create :reset_unwanted_fields
  
  after_update :touch_shares
  
  has_many :grades do
    def for_user(user)
      find :first, :conditions => {:user_id => user.id}
    end
  end
  
  accepts_nested_attributes_for :grades, :allow_destroy => :true 
  
  def score_for(user)
    grades.for_user(user).score if grades.for_user(user)
  end
  has_many :submissions do
    def by(user)
      find :first, :include => :post, :conditions => ["posts.user_id=?", user.id]
    end
  end
  
  def shared_to?(user)
    shares_to_groups.any?{|s|user.groups.include?(s.shared_to)}
  end
  
  def score
    Rubric.trim(self[:score])
  end
  
  
  def reset_unwanted_fields
    due_date = nil unless has_submissions
    start_time = nil unless date
    end_time = nil unless date
  end
  
  def user
    post.owner
  end
  
  def name
    post.title
  end
  
  private
  
  def touch_shares
    puts "self.changed? or self.post.changed? - #{self.changed?.inspect} or #{self.post.changed?.inspect}"
    puts "self.changed? or self.post.changed? - #{self.changes.inspect} or #{self.post.changes.inspect}"
    if self.changed? or self.post.changed?
      for share in shares
        share.touch
        share.update_notifications
      end
    end
  end 
  
end
