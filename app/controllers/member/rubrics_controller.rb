class Member::RubricsController < Member::BaseController
  
  def index
    store_location
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
    @rubrics = (current_user.rubrics  | Share.shared_to_groups_of_type(current_user.groups,'Rubric')).paginate :per_page => 20,
                                 :page => @page,
                                 :order => "title DESC"  
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
        render :update do |page|
          page[:rubric].replace_html :partial => 'member/rubrics/new'
        end
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
      redirect_back_or_default member_rubrics_path
    else
      @rubrics = (current_user.rubrics  | Share.shared_to_groups_of_type(current_user.groups,'Rubric')).paginate :per_page => 20,
                                 :page => @page,
                                 :order => "title DESC"  
      render :action => 'new'
    end
  end
  
  def show
    @rubric = Rubric.find(params[:id])
    respond_to do |format|
      format.js do
        render :update do |page|
          page[:rubric].replace_html :partial => 'member/rubrics/table'
        end
      end
      format.html
    end    
  end
  
  def edit
    @rubric = Rubric.find(params[:id])
  end
  
  def update
    @rubric = Rubric.find(params[:id])
    
    #    due to bug https://rails.lighthouseapp.com/projects/8994/tickets/4766-nested_attributes-fails-to-updatedestroy-when-association-is-loaded-between-setting-attributes-and-saving-parent
    @rubric.levels(true)
    @rubric.criteria(true)
    if @rubric.update_attributes(params[:rubric])
      puts "levels = "+@rubric.levels.inspect
      redirect_to member_rubric_path(@rubric)
    else
      render :action => 'edit'
    end
  end
  
  def add_level
    @rubric = Rubric.new(params[:rubric])
    if @rubric.levels.size > 0
      points = @rubric.levels.first.points == 0 ? @rubric.levels.last.points + 1 :  (@rubric.levels.last.points +  @rubric.levels.first.points) 
    else  
      points = 0
    end
    level = Level.new(:name => "#{I18n.t('rubrics.model.level')}#{@rubric.levels.size+1}", :points => points)
    @rubric.levels << level
    @rubric.criteria.each do |criterion|
      criterion.rubric_descriptors << RubricDescriptor.new(:level => level)
    end
    respond_to do |format|
      format.js {
        render :update do |page|
          page[:rubric].replace_html :partial => 'member/rubrics/new'
        end
      }
    end
  end
  
  def remove_field
    puts "in remove field"
    if params[:id]
      @rubric = Rubric.find(params[:id])
      @rubric.levels(true)
      @rubric.criteria(true)      
      @rubric.attributes = params[:rubric]
    else
      @rubric = Rubric.new(params[:rubric])
      position = (params[:position].to_i) - 1
      if params[:type] == 'level'
        for criterion in @rubric.criteria
          criterion.rubric_descriptors(true)
          criterion.rubric_descriptors.delete_at(position)
        end
        @rubric.levels.delete_at(position)
      elsif params[:type] == 'criterion'
        @rubric.criteria.delete_at(position)
      end
    end    
    puts "rubric = "+@rubric.criteria.inspect
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
    @rubric = Rubric.new(params[:rubric])
    criterion = Criterion.new
    @rubric.levels.each do |level|
      criterion.rubric_descriptors << RubricDescriptor.new(:level => level)
    end
    @rubric.criteria << criterion
    respond_to do |format|
      format.js {
        render :update do |page|
          page[:rubric].replace_html :partial => 'member/rubrics/new'
        end
      }
    end   
  end
  
  
  
end
