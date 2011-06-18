class Submission < ActiveRecord::Base
  
  acts_as_shareable
  belongs_to :assignment
  belongs_to :post
  
  belongs_to :user
  
  accepts_nested_attributes_for :post
  
  after_save :touch_shares  
  
  def submitter
    post.owner
  end
  
  def name
    post.title
  end
  
  private
  
  def touch_shares
    for share in shares
      share.touch
    end
  end
  
end
