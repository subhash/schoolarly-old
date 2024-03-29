class Member::RubricsController < Member::BaseController
  
  before_filter :init_rubric, :only => [:remove_field, :add_criterion, :add_level ]
  
  def index
    @order = params[:order] || 'created_at'
    @page = params[:page] || '1'
    @asc = params[:asc] || 'asc'  
    @rubrics = (current_user.rubrics  | Share.shared_to_groups_of_type(current_user.groups,'Rubric').collect(&:shareable)).paginate :per_page => 20,
                                 :page => @page,
                                 :order => "#{@order} #{@asc}"  
    
  end
  
  def new
    @rubric = Rubric.new
    @rubric.add_default_attributes
    @rubrics = (current_user.rubrics  | Share.shared_to_groups_of_type(current_user.groups,'Rubric').collect(&:shareable)).paginate :per_page => 20,
                                 :page => @page,
                                 :order => "title ASC"  
  end
  
  def new_template
    rubric_old = Rubric.find(params[:id])
    @rubric = Rubric.new
    for level_old in rubric_old.levels
      level = Level.new(:name => level_old.name, :position => level_old.position, :points => level_old.points)
      @rubric.levels << level
    end
    for criterion_old in rubric_old.criteria
      criterion = Criterion.new(:name => criterion_old.name, :weightage => criterion_old.weightage)
      for rd_old in criterion_old.rubric_descriptors  
        rd = RubricDescriptor.new(:description => rd_old.description,:level => @rubric.levels.at(rd_old.level.position - 1))
        criterion.rubric_descriptors << rd
      end
      @rubric.criteria << criterion
    end
    respond_to do |format|
      format.js {
#        render :update do |page|
#          page[:rubric].replace_html :partial => 'member/rubrics/new'
#        end
        render :partial => 'member/rubrics/new'
      }
    end
  end
  
  def create
    @rubric = Rubric.new(params[:rubric])
    @rubric.user = current_user
    for criterion in @rubric.criteria
      for level in @rubric.levels
        rd = criterion.rubric_descriptors[level.position - 1]
        rd.level = level
      end
    end
    if @rubric.save
      redirect_to member_rubrics_path
    else
      @rubrics = (current_user.rubrics  | Share.shared_to_groups_of_type(current_user.groups,'Rubric').collect(&:shareable)).paginate :per_page => 20,
                                 :page => @page,
                                 :order => "title DESC"  
      render :action => 'new'
    end
  end
  
  def show
    @rubric = Rubric.find(params[:id])
    respond_to do |format|
      format.js do
        render :partial => 'member/rubrics/table'
      end
      format.html
    end    
  end
  
  def edit
    @rubric = Rubric.find(params[:id])
    @shared_groups = @rubric.shares_to_groups.collect(&:shared_to)
  end
  
  def update
    @rubric = Rubric.find(params[:id])
    @shared_groups = @rubric.shares_to_groups.collect(&:shared_to)
    
    #    due to bug https://rails.lighthouseapp.com/projects/8994/tickets/4766-nested_attributes-fails-to-updatedestroy-when-association-is-loaded-between-setting-attributes-and-saving-parent
    @rubric.levels(true)
    @rubric.criteria(true)
    if @rubric.update_attributes(params[:rubric])
      redirect_to member_rubric_path(@rubric)
    else
      render :action => 'edit'
    end
  end
  
  def add_level
    if @rubric.levels.size > 0
      points = @rubric.levels.first.points == 0 ? @rubric.levels.last.points + 1 :  (@rubric.levels.last.points +  @rubric.levels.first.points) 
    else  
      points = 0
    end
    level = Level.new(:name => "#{I18n.t('rubrics.model.level')}#{@rubric.levels.size+1}", :points => points)
    @rubric.levels << level
    @rubric.criteria.each do |criterion|
      criterion.rubric_descriptors << RubricDescriptor.new(:level => level, :position => level.position)
    end
    respond_to do |format|
      format.js {
        render :update do |page|
          if params[:id]
            page[:rubric].replace_html :partial => 'member/rubrics/edit'
          else
            page[:rubric].replace_html :partial => 'member/rubrics/new'
          end     
        end
      }
    end
  end
  
  def remove_field
    unless params[:id]
      position = (params[:position].to_i) - 1
      if params[:type] == 'level'
        for criterion in @rubric.criteria
          criterion.rubric_descriptors.delete_at(position)
        end
        @rubric.levels.delete_at(position)
      elsif params[:type] == 'criterion'
        @rubric.criteria.delete_at(position)
      end
    end    
    respond_to do |format|
      format.js {
        render :update do |page|
          if params[:id]
            page[:rubric].replace_html :partial => 'member/rubrics/edit'
          else
            page[:rubric].replace_html :partial => 'member/rubrics/new'
          end         
        end
      }
    end
  end
  
  
  def add_criterion
    criterion = Criterion.new
    @rubric.levels.each do |level|
      criterion.rubric_descriptors << RubricDescriptor.new(:level => level, :position => level.position)
    end
    @rubric.criteria << criterion
    respond_to do |format|
      format.js {
        render :update do |page|
          if params[:id]
            page[:rubric].replace_html :partial => 'member/rubrics/edit'
          else
            page[:rubric].replace_html :partial => 'member/rubrics/new'
          end     
        end
      }
    end   
  end
  
  
  private
  def init_rubric
    if params[:id]
      @rubric = Rubric.find(params[:id])
      @rubric.levels(true)
      @rubric.criteria(true)      
      @rubric.attributes = params[:rubric]
    else
      @rubric = Rubric.new(params[:rubric])
    end
  end
end
