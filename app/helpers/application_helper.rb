# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  include SmerfFormsHelper
  
  def include_form_effects
    include_javascript "jquery-1.4.2.min.js" 
    include_javascript 'form'
  end
  
end
