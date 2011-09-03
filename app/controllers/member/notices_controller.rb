class Member::NoticesController < Member::BaseController
  
  before_filter :find_group
  
  def show
    store_location
    @notice = Notice.find(params[:id])
  end
  
  def create
    @notice = Notice.new params[:notice]
    @notice.user = current_user   
    respond_to do |wants|
      if @notice.save
        wants.html do
          flash[:ok] = I18n.t('groups.member.notices.created')
          @group.share(current_user, @notice.class.to_s, @notice.id)
          redirect_back_or_default member_group_path(@group)
        end
      else
        wants.html do
          render :action => :new            
        end
      end
    end
  end
  
  
  private
  def find_group
    @group = Group.find(params[:group_id]) if params[:group_id]
  end
  
end
