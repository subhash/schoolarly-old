class Notice < ActiveRecord::Base
  acts_as_commentable
  belongs_to :user
  
  has_many :comments, :order => "created_at DESC", :as => :commentable
  
  def title
    content
  end
  
end
