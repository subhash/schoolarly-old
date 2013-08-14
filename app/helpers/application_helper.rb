# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  include SmerfFormsHelper
  
  def include_form_effects
    include_javascript "jquery-1.4.2.min.js" 
    include_javascript 'form'
  end
  
  def include_jquery
    include_javascript 'jquery-1.8.1.min.js'
  end
  
  def include_pretty_photo    
    include_javascript 'prettyPhoto/jquery.prettyPhoto.js'
    include_javascript 'photo'
    include_stylesheet 'prettyPhoto/prettyPhoto.css'
    include_stylesheet 'prettyPhoto/pp_upgrade.css'
  end
  
  def include_bootstrap
    include_javascript 'bootstrap/bootstrap.js'
  end
  
  def include_list_filters
    include_stylesheet 'jplist/normalize'
    include_stylesheet 'jplist/styles'
    include_stylesheet 'jplist/div'
    include_stylesheet 'jplist/toggle-filters'
    include_javascript 'jplist/jplist.min.js'
    include_javascript 'jplist/jplist.checkbox-filters.min.js'
    include_javascript 'jplist/jplist.default-sort.min.js'
    include_javascript 'list'
  end
  
  #  def include_list_filters
  #    include_javascript 'jplist/jplist.js'
  #    include_javascript 'jplist/blocks/collection.js'
  #    include_javascript 'jplist/blocks/controller.js'
  #    include_javascript 'jplist/blocks/cookies.js'
  #    include_javascript 'jplist/blocks/dataitem.js'
  #    include_javascript 'jplist/blocks/dropdown.js'
  #    include_javascript 'jplist/blocks/filters.js'
  #    include_javascript 'jplist/blocks/helper.js'
  #    include_javascript 'jplist/blocks/label.js' 
  #    include_javascript 'jplist/blocks/paging.js'
  #    include_javascript 'jplist/blocks/panel.js'
  #    include_javascript 'jplist/blocks/panel-control.js'
  #    include_javascript 'jplist/blocks/path.js'
  #    include_javascript 'jplist/blocks/pathitem.js'
  #    include_javascript 'jplist/blocks/placeholder.js'
  #    include_javascript 'jplist/blocks/sort.js'
  #    include_javascript 'jplist/blocks/status.js'
  #    include_javascript 'jplist/blocks/textbox.js'
  #  end
  
  def include_table_filter
    include_javascript 'busy_ajax'
    include_javascript 'jquery-1.4.2.min' 
    include_javascript 'tableFilter/tablefilter_all'
    include_javascript 'table'
    include_stylesheet 'upgrade_filtergrid'
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
  
  
  def title(share)
    entry = share.shareable
    case share.shareable_type
      when "Quiz"
      "Quiz: #{entry.title}"
      when "Notice"
      "Notice"
      when "Assignment", "Submission"
      entry.name
      when "Grade"       
      entry.assignment.name
    else
      entry.title
    end
  end
  
  def member_link(share)
    entry = share.shareable
    case share.shareable_type
      when "Video"
      member_video_path(entry)
      when "Picto::Photoset"
      member_picto_photoset_path(entry)
      when "Picto::Photo"
      member_picto_photo_path(entry)
      when "Post"
      member_conversatio_post_path(entry)
      when "Event"
      member_conclave_event_path(entry)
      when "Assignment"
      member_assignment_path(entry)
      when "Notice"
      member_group_notice_path(share.shared_to, entry)
      when "Submission"
      member_submission_path(entry)
      when "Grade"       
      #member_assignment_path(entry.assignment)
      member_grade_path(entry)
      when "Quiz"
      my_quiz_path(entry)
    end
  end
  
  def theme(share)
    case share.shareable_type
      when "Video"
        "<span class=\"video\">Video</span>"
      when "Picto::Photo","Picto::Photoset"
        "<span class=\"photo\">Photo</span>"
      when "Post"
        "<span class=\"note\">#{link_to icon_for_post, member_link(share)}</span>"
      when "Event"
        "<span class=\"event\">#{link_to icon_for_event, member_link(share)}</span>"
      when "Assignment"
        "<span class=\"assignment\">#{link_to icon_for_assignment(share.shareable), member_link(share)}</span>"
      when "Notice"
        "<span class=\"message\">#{link_to icon_for_notice, member_link(share)}</span>"
      when "Submission"
        "<span class=\"submission\">#{link_to icon_for_submission, member_link(share)}</span>"
      when "Grade"       
        "<span class=\"grade\">#{link_to icon_for_grade,  member_link(share)}</span>"
    else
        "<span class=\"quiz\">Quiz</span>"
    end    
  end
  
  def time_ago(share)
    entry = share.shareable
    case share.shareable_type
      when "Picto::Photoset", "Picto::Photo", "Video", "Grade" 
      I18n.t('assignments.site.list_detail.time_ago', :time => time_ago_in_words(share.updated_at))
      when "Post"
      I18n.t('assignments.site.list_detail.time_ago', :time => time_ago_in_words(entry.published_at))
      when "Assignment"
      if entry.post.published?
        I18n.t('assignments.site.list_detail.time_ago', :time => time_ago_in_words(entry.post.published_at)) 
      else
        I18n.t('assignments.site.list_detail.from_now', :time => time_ago_in_words(entry.post.published_at)) 
      end 
      when "Submission"
      I18n.t('assignments.site.list_detail.time_ago', :time => time_ago_in_words(entry.post.published_at))
    else
      I18n.t('assignments.site.list_detail.time_ago', :time => time_ago_in_words(entry.created_at))
    end  
  end
end
