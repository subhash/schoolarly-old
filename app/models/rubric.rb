class Rubric < ActiveRecord::Base
  
  has_many :criteria, :order => 'position', :dependent => :destroy
  has_many :levels, :order => 'position', :dependent => :destroy
  belongs_to :user
  
  validates_presence_of :title
  validates_presence_of :criteria
  validates_presence_of :levels
  
  accepts_nested_attributes_for :criteria
  accepts_nested_attributes_for :levels
  
  has_many :rubric_descriptors, :through => :criteria, :dependent => :destroy do
    def of(criterion, level)
      find :first, :conditions => {:criterion_id => criterion.id, :level_id => level.id}
    end
  end
  
  def add_default_attributes
    level1 = Level.new(:name => "Poor")
    level2 = Level.new(:name => "Average")
    level3 = Level.new(:name => "Good")
    level4 = Level.new(:name => "Excellent")
    self.levels = [level1,level2,level3,level4]
    criterion = Criterion.new
    criterion.rubric_descriptors << RubricDescriptor.new(:level => level1)
    criterion.rubric_descriptors << RubricDescriptor.new(:level => level2)
    criterion.rubric_descriptors << RubricDescriptor.new(:level => level3)
    criterion.rubric_descriptors << RubricDescriptor.new(:level => level4)
    self.criteria << criterion
  end
  
end
