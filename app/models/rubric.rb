class Rubric < ActiveRecord::Base
  
  acts_as_shareable
  acts_as_commentable  # added as dummy entry to make eager loading of comments possible in dashboard
  has_many :shares_to_groups, :class_name => 'Share', :as => :shareable, :conditions => {:shared_to_type => 'Group'}
  has_many :criteria, :order => 'position', :include => :rubric_descriptors, :dependent => :destroy
  has_many :levels, :order => 'position', :dependent => :destroy do
    def at(position)
      find :first, :conditions => {:position => position}
    end
  end
  belongs_to :user
  
  validates_presence_of :title
  validates_presence_of :criteria
  validates_presence_of :levels
  validate :weightage_summation
  
  accepts_nested_attributes_for :criteria, :levels, :allow_destroy => true
  
  
  def weightage_summation   
    unless criteria.select{|c|c.weightage}.blank?
      unless (criteria.collect(&:weightage).sum == 100)
        errors.add(:weightage, "should addup to 100%")
      end
    end
  end
  
  has_many :assignments
  
  has_many :rubric_descriptors, :through => :criteria, :dependent => :destroy do
    def of(criterion, level)
      find :first, :conditions => {:criterion_id => criterion.id, :level_id => level.id}
    end
  end
  
  def add_default_attributes
    level1 = Level.new(:points => 1)
    level2 = Level.new(:points => 2)
    level3 = Level.new(:points => 3)
    level4 = Level.new(:points => 4)
    self.levels = [level1,level2,level3,level4]
    criterion1 = Criterion.new(:weightage => 30)
    criterion2 = Criterion.new(:weightage => 30)
    criterion3 = Criterion.new(:weightage => 40)
    self.criteria = [criterion1,criterion2,criterion3]
    for criterion in self.criteria
      criterion.rubric_descriptors << RubricDescriptor.new(:level => level1)
      criterion.rubric_descriptors << RubricDescriptor.new(:level => level2)
      criterion.rubric_descriptors << RubricDescriptor.new(:level => level3)
      criterion.rubric_descriptors << RubricDescriptor.new(:level => level4)
    end
  end
  
  def max_points
    Rubric.trim(levels.maximum(:points))
  end
  
  def self.trim(number)
    number.to_i == number ? number.to_i : number
  end
  
  def grade_type?
    criteria.size == 1 and max_points.blank?
  end
  
  def editable?
    for rd in rubric_descriptors
      return false if rd.grade_rubric_descriptors.any?
    end
    return true
  end
  
  
end
