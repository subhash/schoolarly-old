class Aggregation < ActiveRecord::Base
  
  acts_as_shareable
  
  has_many :assignments, :dependent => :nullify
  has_many :aggregations
  accepts_nested_attributes_for :assignments
  accepts_nested_attributes_for :aggregations

    
  acts_as_tree
  
  def self_and_all_children
    self.children.inject([self]) { |array, child| array += child.self_and_all_children }.flatten
  end
  
  def all_children
    self_and_all_children - [self]
  end
  
  def preorder(&b)
    yield b, self
    for child in self.children
      child.preorder(b)
    end
  end
  
  
  def nodes
    children + assignments
  end
  
  
  def set_score_weightages
    score = [aggregations.maximum(&:score), assignments.maximum(&:score)].max
    puts "score = "+score.inspect
    for node in nodes
      node.weightage = 100/nodes.size
      puts "weightage = "+node.weightage.inspect
    end
  end
  
end
