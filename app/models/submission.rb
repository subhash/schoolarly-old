class Submission < ActiveRecord::Base
  
  acts_as_shareable
  acts_as_commentable # added as dummy entry to make eager loading of comments possible in dashboard
  acts_as_sanitized
  
  belongs_to :assignment
  belongs_to :post
  
  belongs_to :user
  
  accepts_nested_attributes_for :post
  
  after_update :touch_shares   
  
  has_many :shares, :class_name => 'Share', :as => :shareable do
    def to_user(user_id, by)
      find :first, :conditions => {:shared_to_type => 'User', :shared_to_id => user_id, :user_id => by }
    end
  end
  
  has_many :shares_to_groups, :class_name => 'Share', :as => :shareable, :conditions => {:shared_to_type => 'Group'}, :include => {:shared_to => [:parent] }
  
  def submitter
    post.owner
  end
  
  def name
    post.title
  end
  
  def returned_to?(to_user)
    self.shares.to_user(to_user, assignment.user) && (to_user == self.user) && (to_user!= assignment.user)
  end
  
  
  def late?
    return false if assignment.post.owner == self.post.owner
    assignment.due_date ? (post.published_at && post.published_at > assignment.due_date) : false
  end
  
  private
  
  def touch_shares
    if self.changed?
      for share in shares
        share.touch
      end
    end
  end
  
end
