class Member::GradesController < Member::BaseController
  
  before_filter :find_assignment, :only => [:new, :create]
  
  before_filter :find_grade, :only => [:edit, :update, :destroy, :show]
  
  def new
    @user = User.find(params[:user_id])
    @grade = Grade.new(:assignment => @assignment, :user => @user, :rubric_descriptors => [])
    respond_to do |format|
      format.html{
        @profile = @user.profile
        render :template => 'member/grades/new'
      }
      format.js {
        render :partial => 'new'
      }
    end
  end
  
  def create
    @grade = Grade.new(params[:grade])
    if params[:rubric_descriptors]
      desc_ids = params[:rubric_descriptors].values.map{|v| v["id"]}
      @grade.rubric_descriptor_ids = desc_ids
    end
    respond_to do |format|
      format.js {
        if @grade.save   
          render :partial => 'show'
        else 
          render :partial => 'new'
        end
      }
    end
  end
  
  def edit
    respond_to do |format|
      format.js {
        render :partial => 'edit'
      }
    end
  end
  
  
  def update
    puts "grade before - "+@grade.inspect
    @grade.attributes = params[:grade]
    puts "grade after - "+@grade.inspect
    if params[:rubric_descriptors]
      desc_ids = params[:rubric_descriptors].values.map{|v| v["id"]}
      @grade.rubric_descriptor_ids = desc_ids
    end
    respond_to do |format|
      format.js {
        if @grade.save   
          render :partial => 'show'
        else 
          render :partial => 'edit'
        end
      }
    end
  end
  
  def destroy
    respond_to do |format|
      format.js {
        if @grade.destroy   
          render :partial => 'empty'
        else 
          render :partial => 'show'
        end
      }
    end
  end
  
  def change_rubric
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
    @assignment = @grade.assignment
    @user = @grade.user
    @profile = @user.profile
  end
  
end
