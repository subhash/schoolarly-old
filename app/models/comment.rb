class Comment < ActiveRecord::Base
  
  include ActsAsCommentable::Comment
  
  acts_as_textiled :comment
  acts_as_sanitized
  
  belongs_to :commentable, :polymorphic => true
  
  after_create :touch_shares
  
  # NOTE: install the acts_as_votable plugin if you
  # want user to vote on the quality of comments.
  #acts_as_voteable
  
  # NOTE: Comments belong to a user
  belongs_to :user
  
  def touch_shares
    for share in  commentable.shares
      share.touch
    end
  end
  
  def after_find
    textilize
  end
  
end