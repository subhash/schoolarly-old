class Assignment < ActiveRecord::Base 
  
  belongs_to :activity, :polymorphic => true
  
  belongs_to :post, :dependent => :destroy
  
  has_many :shares_to_groups, :class_name => 'Share', :as => :shareable, :conditions => {:shared_to_type => 'Group'}
  
  accepts_nested_attributes_for :post
  
  belongs_to :rubric
  
  has_one :weighted_assignment
  
  has_many :grades do
    def for_user(user)
      find :first, :conditions => {:user_id => user.id}
    end
  end
  
  has_many :submissions do
    def by(user)
      find :first, :include => :post, :conditions => ["posts.user_id=?", user.id]
    end
  end
  
  def shared_to?(user)
    shares_to_groups.any?{|s|user.groups.include?(s.shared_to)}
  end
  
  def home?
    activity_type == 'HomeActivity'
  end
  
  def klass?
    activity_type == 'ClassActivity'
  end
  
end
