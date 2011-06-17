# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  include SmerfFormsHelper
  
  def include_form_effects
    include_javascript "jquery-1.4.2.min.js" 
    include_javascript 'form'
  end
  
  def shared_through_whom(share)
    whom = []
    if share.shared_to.is_a? Group
      unless current_user.groups.include? share.shared_to
        whom = share.shared_to.memberships_of(current_user.friend_users).map(&:user)
      end
    elsif share.shared_to.is_a? User
      whom = [share.shared_to] 
    end
    whom
  end
  
  
  def i_am_the_owner_of?(object)
    case(object.class.name) 
      when 'Event', 'Post'
      object.owner == current_user
      when 'Assignment'
      object.post.owner == current_user
    else
      object.user == current_user
    end
    
  end
  
  
end
