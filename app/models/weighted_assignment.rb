class WeightedAssignment < ActiveRecord::Base
  
  belongs_to :assignment
  belongs_to :aggregation
  
  
  def name
    assignment.post.title
  end
  
  def score
    assignment.score
  end
end
