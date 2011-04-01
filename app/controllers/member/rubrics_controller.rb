class Member::RubricsController < Member::BaseController
  
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
    @rubrics = (current_user.rubrics  | Share.shared_to_groups_of_type(current_user.groups,'Rubric')).paginate :per_page => 20,
                                 :page => @page,
                                 :order => "title DESC"  
  end
  
  def new_template
    rubric_old = Rubric.find(params[:rubric_id])
    @rubric = Rubric.new
    for level_old in rubric_old.levels
      level = Level.new(:name => level_old.name, :position => level_old.position)
      @rubric.levels << level
    end
    for criterion_old in rubric_old.criteria
      criterion = Criterion.new(:name => criterion_old.name)
      for rd_old in criterion_old.rubric_descriptors  
        rd = RubricDescriptor.new(:description => rd_old.description,:level => @rubric.levels.at(rd_old.level.position))
        criterion.rubric_descriptors << rd
      end
      @rubric.criteria << criterion
    end
    respond_to do |format|
      format.js {
        render :update do |page|
          page[:rubric].replace_html :partial => 'member/rubrics/form'
        end
      }
    end
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
      @rubrics = (current_user.rubrics  | Share.shared_to_groups_of_type(current_user.groups,'Rubric')).paginate :per_page => 20,
                                 :page => @page,
                                 :order => "title DESC"  
      render :action => 'new'
    end
  end
  
  def show
    @rubric = Rubric.find(params[:id])
  end
  
  def edit
    puts "edit #{params.inspect}"
    @rubric = Rubric.find(params[:id])
  end
  
  def update
    puts "update #{params.inspect}"
    obj, id, attr = params[:element].split("_")
    record = case obj 
      when 'level' then Level.find(id)
      when 'criterion' then Criterion.find(id)
      when 'rubric_descriptor' then RubricDescriptor.find(id)
    end
    record[attr] = params[:value]
    if record.save
      respond_to do |wants|
        wants.js 
      end
    end
  end
  
  def see
    puts "see #{params.inspect}"
    puts "request #{request.inspect}"
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
