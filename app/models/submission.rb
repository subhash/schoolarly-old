class Submission < ActiveRecord::Base
  
  acts_as_shareable
  belongs_to :assignment
  belongs_to :post
  
  belongs_to :user
  
  accepts_nested_attributes_for :post
  
  
  def submitter
    post.owner
  end
  
  def name
    post.title
  end
  
  
end
