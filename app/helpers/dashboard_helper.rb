module DashboardHelper
  
  def icon_for_assignment(assignment, options={})
    if assignment.has_submissions
      return image_tag("/images/#{config["plugins.schoolarly.homeactivity.image.default"]}" , options)
    else
      return image_tag("/images/#{config["plugins.schoolarly.classactivity.image.default"]}" , options)
    end
  end    
  
  def icon_for_aggregation(options={})
    return image_tag("/images/#{config["plugins.schoolarly.aggregation.image.default"]}" , options)
  end
  
  def icon_for_submission(options={})
    return image_tag("/images/#{config["plugins.schoolarly.submission.image.default"]}" , options)
  end
  
  
  def icon_for_attachment(options={})
    return image_tag("/images/#{config["plugins.schoolarly.attachment.image.default"]}" , options)
  end
  
  def icon_for_post(options={})
    return image_tag("/images/#{config["plugins.schoolarly.post.image.default"]}" , options)
  end
  
  def icon_for_event(options={})
    return image_tag("/images/#{config["plugins.schoolarly.event.image.default"]}" , options)
  end
  
  def icon_for_notice(options={})
    return image_tag("/images/#{config["plugins.schoolarly.notice.image.default"]}" , options)
  end
  
  def display?(share)
    !share.shareable.is_a? Rubric and !share.shareable.is_a? Aggregation and !share.shareable.is_a? Grade
  end
  
end
