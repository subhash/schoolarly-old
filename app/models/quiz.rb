class Quiz < ActiveRecord::Base
  
  belongs_to :user
  acts_as_commentable  # added as dummy entry to make eager loading of comments possible in dashboard
  
  has_many :quiz_responses do
    def by(user)
      find :first, :conditions => {"quiz_responses.user_id" => user.id}
    end
  end
  
  has_many :shares_to_groups, :class_name => 'Share', :as => :shareable, :conditions => {:shared_to_type => 'Group'}
  
end
