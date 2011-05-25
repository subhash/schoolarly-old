class Member::ReportsController < Member::BaseController
  
  before_filter :find_group
  
  def new   
    @aggregations = @group.sharings.of_type('Aggregation').collect(&:shareable).reject(&:parent)
    @assignments = @group.sharings.of_type('Assignment').collect(&:shareable).reject(&:weighted_assignment)
  end
  
  
  private
  def find_group
    @group = Group.find(params[:group_id]) if params[:group_id]
  end
end
