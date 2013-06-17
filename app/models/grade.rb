class Grade < ActiveRecord::Base
  
  acts_as_commentable  # added as dummy entry to make eager loading of comments possible in dashboard
  belongs_to :user
  belongs_to :assignment
  
  has_many :grade_rubric_descriptors, :dependent => :destroy
  has_many :rubric_descriptors, :through => :grade_rubric_descriptors
  
  validates_numericality_of :score, :greater_than_or_equal_to => 0
  
  validate :valid_score?, :if => Proc.new { |grade| grade.assignment.score }, :if => :score
  
  acts_as_shareable
  
  after_update :touch_shares  
  
  def grade_points
    Rubric.trim(rubric_descriptors.collect(&:points).sum)
  end
  
  def rubric_points
    assignment.rubric.grade_type? ?  "Grade: #{rubric_descriptors.first.level.name}" : "#{grade_points}/#{assignment.rubric.max_points}"
  end
  
  def score
    Rubric.trim(self[:score])
  end
  
  def touch_shares
    if self.changed?
      for share in shares
        share.touch
      end
    end
  end 
  
  protected
  def valid_score?
    errors.add(:score, I18n.t('grades.model.score.invalid', :score => assignment.score )) if (score >= assignment.score)
  end 
  
end
