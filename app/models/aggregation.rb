class Aggregation < ActiveRecord::Base
  
  acts_as_shareable
  
  has_many :weighted_assignments, :dependent => :destroy
  has_many :assignments, :through => :weighted_assignments
  
  belongs_to :user
  acts_as_tree

#  has_many :children, :class_name => 'Aggregation', :foreign_key => 'parent_id', :dependent => :nullify
  
  accepts_nested_attributes_for :weighted_assignments, :allow_destroy => true
  accepts_nested_attributes_for :children, :allow_destroy => true
  validates_presence_of :name
  validates_presence_of :score
  
  
  #  validates_presence_of :score
  #  validates_presence_of :name
  #  validates_numericality_of :weightage, :greater_than_or_equal_to => 0, :less_than_or_equal_to => 100
  #  validate :weightage_summation, :if => :weighted_average
  
  
#  def self_and_all_children
#    self.children.inject([self]) { |array, child| array += child.self_and_all_children }.flatten
#  end
#  
#  def all_children
#    self_and_all_children - [self]
#  end
  
  
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
    score =  [children.maximum("score"), assignments.maximum("score")].max if assignments.maximum("score")
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
  
  def score
    Rubric.trim(self[:score])
  end

  def score_for(user)
    if weighted_average 
      return nodes.collect{|n| (n.score_for(user) and n.score) ? ((n.score_for(user)/n.score.to_f) * (n.weightage/100.00) * score.to_f) : 0.0}.sum
    else
      return (nodes.collect{|n| (n.score_for(user) and n.score) ? ((n.score_for(user)/n.score.to_f) * score.to_f) : 0.0}.sum)/nodes.size
    end
    end
    
    def formula
      str = ""
      if weighted_average
        for child in nodes
          str << "("+child.weightage.to_s+"% of "+child.name+")+"
        end
        str.chop!
      else  
        str =  "Average(" + nodes.collect(&:name) * ", " + ")"
      end   
    end
  end
