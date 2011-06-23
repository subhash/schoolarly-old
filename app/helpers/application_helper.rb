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
      whom = [share.shared_to] if current_user.friend_users.include? share.shared_to
    end
    whom
  end
  
  
  def site_title
    if current_user and current_user.school
      link_to current_user.school.group.name, member_group_path(current_user.school.group)
    else
      link_to 'Schoolarly', '/'
    end
    
  end
  
end
