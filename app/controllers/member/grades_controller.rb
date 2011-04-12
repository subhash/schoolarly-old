class Member::GradesController < Member::BaseController
  
  before_filter :find_assignment, :only => [:create]
  
  before_filter :find_grade
  
  def create
    @grade = Grade.new(params[:grade])
    if params[:rubric_descriptors]
      desc_ids = params[:rubric_descriptors].values.map{|v| v["id"]}
      @grade.rubric_descriptor_ids = desc_ids
    end
    if @grade.save
      puts @grade.inspect
      redirect_to member_assignment_path(@assignment)
    else 
      puts @grade.errors.inspect
      render :new
    end
  end
  
  def change_rubric
    puts 'hoo - '+params.inspect
    puts 'req - '+request.inspect
    if params[:rubric_descriptor]
      @descriptor = RubricDescriptor.find(params[:rubric_descriptor])
      puts 'replacing with '+@descriptor.inspect
      puts 'before - '+@grade.rubric_descriptors.inspect
      @grade.grade_rubric_descriptors.select {|grd| 
        grd.rubric_descriptor.criterion == @descriptor.criterion 
      }.each{|grd| grd.destroy }
      puts 'after - '+@grade.rubric_descriptors.inspect
      @grade.rubric_descriptors << @descriptor
      if @grade.save
        puts 'done - '+@grade.rubric_descriptors.inspect
      end
    end
    
  end
  
  private
  
  def find_assignment
    @assignment = Assignment.find(params[:assignment_id]) if params[:assignment_id]
  end
  
  def find_grade
    @grade = Grade.find(params[:id]) if params[:id]
  end
  
end
