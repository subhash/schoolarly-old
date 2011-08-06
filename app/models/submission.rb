class Submission < ActiveRecord::Base
  
  acts_as_shareable
  belongs_to :assignment
  belongs_to :post
  
  belongs_to :user
  
  accepts_nested_attributes_for :post
  
  after_update :touch_shares  
  
  def submitter
    post.owner
  end
  
  def name
    post.title
  end
  
  def late?
    return false if assignment.post.owner == self.post.owner
    assignment.due_date ? post.published_at > assignment.due_date : false
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
