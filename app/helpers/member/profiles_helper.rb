module Member::ProfilesHelper
  
  def i_am_school_moderator_for(profile)
    profile.user.school and profile.user.school.group.moderators.include?(current_user)
  end
  
end