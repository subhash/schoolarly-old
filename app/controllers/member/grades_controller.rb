class Member::GradesController < Member::BaseController
  
  def create
    @assignment = Assignment.find(params[:id])
    @grade = Grade.new(params[:grade])
    if @grade.save
      
    end
  end

end
