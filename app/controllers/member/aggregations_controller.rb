class Member::AggregationsController < Member::BaseController
  before_filter :find_group
  
  
  def new
    @aggregation = Aggregation.new(params[:aggregation])
    @aggregation.set_score_weightages
    puts "aggergation = "+@aggregation.assignments.inspect
  end
  
  def create
    @aggregation = Aggregation.new(params[:aggregation])
    @aggregation.name = "untitled"
    @aggregation.save
    @group.share(current_user, @aggregation.class.to_s, @aggregation.id)
    @aggregations = @group.sharings.of_type('Aggregation').collect(&:shareable).reject(&:parent)
    @assignments = @group.sharings.of_type('Assignment').collect(&:shareable).reject(&:aggregation)
    render :update do |page|
      page[:reports].replace_html :partial => 'member/reports/form'
    end
  end
  
  private
  def find_group
    @group = Group.find(params[:group_id]) if params[:group_id]
  end
  
end
