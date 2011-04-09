class Rubric < ActiveRecord::Base
  
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
  
  accepts_nested_attributes_for :criteria, :levels, :allow_destroy => true

  
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
    criterion1 = Criterion.new(:weightage => 25)
    criterion2 = Criterion.new(:weightage => 25)
    criterion3 = Criterion.new(:weightage => 25)
    criterion4 = Criterion.new(:weightage => 25)
    self.criteria = [criterion1,criterion2,criterion3,criterion4]
    for criterion in self.criteria
      criterion.rubric_descriptors << RubricDescriptor.new(:level => level1)
      criterion.rubric_descriptors << RubricDescriptor.new(:level => level2)
      criterion.rubric_descriptors << RubricDescriptor.new(:level => level3)
      criterion.rubric_descriptors << RubricDescriptor.new(:level => level4)
    end
  end
  
end
