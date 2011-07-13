class Member::AggregationsController < Member::BaseController
  before_filter :find_group
  
  
  def new
    @aggregation = Aggregation.new(params[:aggregation])
    if params[:report]
      @order_by = params[:order_by] || "profiles.first_name, profiles.last_name"
      @sort_order = params[:sort_order] || "asc"
      @page = params[:page] || '1'
      @student_users = @group.student_users.find(:all, :include => :profile, :order => "#{@order_by} #{@sort_order}")
      @aggregations = Aggregation.find(@aggregation.child_ids)
      @assignments = Assignment.find(@aggregation.weighted_assignments.collect(&:assignment_id))
      render :action => :report
    else
      @aggregation.set_score_weightages
      render :action => :new
    end
  end
  
  def create
    @aggregation = Aggregation.new(params[:aggregation])
    params[:children].each do |k, v|
      child = Aggregation.find(k)
      child.update_attributes(v)
      @aggregation.children << child
    end if params[:children]
    @aggregation.user = current_user
    if @aggregation.save
      @group.share(current_user, @aggregation.class.to_s, @aggregation.id)
      @aggregations = @group.sharings.of_type('Aggregation').collect(&:shareable).reject(&:parent)
      @assignments = @group.sharings.of_type('Assignment').collect(&:shareable).reject(&:weighted_assignment)
      redirect_to member_group_aggregations_path(@group)
    else
      render :template => 'new'
    end  
    #    respond_to do |wants|
    #      wants.html{ redirect_to new_member_group_report_path(@group)}
    #      wants.js{
    #        render :update do |page|
    #          page[:reports].replace_html :partial => 'member/reports/form'
    #        end
    #      }
    #    end
  end
  
  def destroy
    @aggregation = Aggregation.find(params[:id])
    @aggregation.destroy
    redirect_to member_group_aggregations_path(@group)
  end
  
  def index
    store_location
    @aggregations = @group.sharings.of_type('Aggregation').collect(&:shareable).reject(&:parent)
    @assignments = @group.sharings.of_type('Assignment').collect(&:shareable).reject(&:weighted_assignment)    
  end
  
  private
  def find_group
    @group = Group.find(params[:group_id]) if params[:group_id]
  end
  
end
