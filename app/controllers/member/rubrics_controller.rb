class Member::RubricsController < Member::BaseController
  
  in_place_edit_for :rubric, :title
  in_place_edit_for :category, :name
  in_place_edit_for :level, :name
  in_place_edit_for :rubric_descriptor, :description
  
  def index
    @order = params[:order] || 'created_at'
    @page = params[:page] || '1'
    @asc = params[:asc] || 'desc'  
    @rubrics = (current_user.rubrics  | Share.shared_to_groups_of_type(current_user.groups,'Rubric')).paginate :per_page => 20,
                                 :page => @page,
                                 :order => "title DESC"  
    
  end
  
  def new
    @rubric = Rubric.new
    @rubric.add_default_attributes
  end
  
  def create
    @rubric = Rubric.new(params[:rubric])
    @rubric.user = current_user
    for criterion in @rubric.criteria
      for level in @rubric.levels
        rd = criterion.rubric_descriptors[level.position]
        rd.level = level
      end
    end
    if @rubric.save
      redirect_back_or_default member_rubrics_path
    else
      render :action => 'new'
    end
  end
  
  def show
    @rubric = Rubric.find(params[:id])
  end
  
  def add_level
    @rubric = Rubric.new(params[:rubric])
    level = Level.new
    @rubric.levels << level
    @rubric.criteria.each do |criterion|
      criterion.rubric_descriptors << RubricDescriptor.new(:level => level)
    end
    respond_to do |format|
      format.js {
        render :update do |page|
          page[:rubric].replace_html :partial => 'member/rubrics/form'
        end
      }
    end
  end
  
  def add_criterion
    @rubric = Rubric.new(params[:rubric])
    criterion = Criterion.new
    @rubric.levels.each do |level|
      criterion.rubric_descriptors << RubricDescriptor.new(:level => level)
    end
    @rubric.criteria << criterion
    respond_to do |format|
      format.js {
        render :update do |page|
          page[:rubric].replace_html :partial => 'member/rubrics/form'
        end
      }
    end   
  end
  
end
