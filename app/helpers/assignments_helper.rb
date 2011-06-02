module AssignmentsHelper
  
  def include_mootools_datepicker
    include_javascript "mootools/mootools-core-1.3.2-full-compat-yc.js" 
    include_javascript 'mootools/datepicker.js'
    include_stylesheet 'datepicker/datepicker.css'
  end
  
end
