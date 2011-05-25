class Aggregation < ActiveRecord::Base
  
  acts_as_shareable
  
  has_many :weighted_assignments, :dependent => :destroy
  has_many :assignments, :through => :weighted_assignments
  
  
  acts_as_tree
  
  accepts_nested_attributes_for :weighted_assignments, :allow_destroy => true
  accepts_nested_attributes_for :children
  
  #  validates_presence_of :score
  #  validates_presence_of :name
  #  validates_numericality_of :weightage, :greater_than_or_equal_to => 0, :less_than_or_equal_to => 100
  #  validate :weightage_summation, :if => :weighted_average
  
  
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
    children + weighted_assignments
  end
  
  
  def set_score_weightages
    #    score = [aggregations.maximum(&:score), assignments.maximum(&:score)].max
    for node in nodes
      node.weightage = 100/nodes.size
    end
    nodes.last.weightage = (100 - nodes.to(nodes.size-2).sum(&:weightage)).to_i
  end
  
  def weightage_summation   
    unless (nodes.collect(&:weightage).sum == 100)
      errors.add(:weightage, "should addup to 100%")
    end
  end
  
end
