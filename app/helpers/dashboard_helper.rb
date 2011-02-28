module DashboardHelper
  
  def icon_for_assignment(options={})
    return image_tag("/images/#{config["plugins.schoolarly.assignment.image.default"]}" , options)
  end
  
    
  def icon_for_attachment(options={})
    return image_tag("/images/#{config["plugins.schoolarly.attachment.image.default"]}" , options)
  end
end