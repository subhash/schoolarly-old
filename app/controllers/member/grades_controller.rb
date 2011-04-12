class Member::GradesController < Member::BaseController
  
  def create
    @assignment = Assignment.find(params[:assignment_id])
    @grade = Grade.new(params[:grade])
    desc_ids = params[:rubric_descriptors].values.map{|v| v["id"]}
    @grade.rubric_descriptor_ids = desc_ids
    if @grade.save
      puts @grade.inspect
      redirect_to member_assignment_path(@assignment)
    else 
      puts @grade.errors.inspect
      render :new
    end
  end

end
