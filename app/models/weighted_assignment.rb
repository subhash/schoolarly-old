class WeightedAssignment < ActiveRecord::Base
  
  belongs_to :assignment
  belongs_to :aggregation
  
  
  def name
    assignment.post.title
  end
  
  def score
    assignment.score
  end
  
  def self_and_all_nodes
    [self]
  end
  
  def  score_for(user)
    assignment.grades.for_user(user).score if assignment.grades.for_user(user)
  end
  
end
