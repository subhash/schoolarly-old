module DashboardHelper
  
  def icon_for_assignment(assignment, options={})
    if assignment.has_submissions
      return image_tag("/images/dashboard/homeactivity2.png" , options)
    else
      return image_tag("/images/dashboard/classactivity.png" , options)
    end
  end    
  
  def icon_for_aggregation(options={})
    return image_tag("/images/dashboard/aggregation2.png" , options)
  end
  
  def icon_for_submission(options={})
    return image_tag("/images/dashboard/submission2.png" , options)
  end
  
  def icon_for_grade(options={})
    return image_tag("/images/dashboard/grade2.png" , options)
  end
  
  def icon_for_attachment(options={})
    return image_tag("/images/dashboard/document2.png" , options)
  end
  
  def icon_for_post(options={})
    return image_tag("/images/dashboard/note2.png" , options)
  end
  
  def icon_for_event(options={})
    return image_tag("/images/dashboard/event2.png" , options)
  end
  
  def icon_for_notice(options={})
    return image_tag("/images/dashboard/notice2.png" , options)
  end
  
  def display?(share)
    !share.shareable.is_a? Rubric and !share.shareable.is_a? Aggregation
  end
  
end
