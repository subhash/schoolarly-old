class Member::GroupsController < Member::BaseController
  def new
      @parent = Group.find(params[:id]) if params[:id]
      @group = Group.new(:parent => @parent)
  end
end