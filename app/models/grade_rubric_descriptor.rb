class GradeRubricDescriptor < ActiveRecord::Base
  
  belongs_to :grade
  belongs_to :rubric_descriptor
  
end
