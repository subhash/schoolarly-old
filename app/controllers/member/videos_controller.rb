class Member::VideosController < Member::BaseController
  before_filter :find_group
  before_filter :find_video, :except => [:new, :create]
  
  def create
    @video = Video.new(params[:video])
    @video.user = current_user
    respond_to do |wants|
      wants.html do
        if @video.save
          @group.share(current_user, @video.class.to_s, @video.id) if @group
          flash[:ok] = I18n.t('videos.member.add_success')
          redirect_to member_video_path(@video, :group => @group)
        else                              
          flash[:error] = I18n.t('videos.member.add_failure')
          render :new
        end  
      end
    end
  end
  
  def update
    respond_to do |wants|
      wants.html do
        if @video.update_attributes(params[:video])
          flash[:ok] = I18n.t('videos.member.update_success')
          redirect_to member_video_path(@video, :group => @group)
        else                              
          flash[:error] = I18n.t('videos.member.update_failure')
          render :edit
        end  
      end
    end
  end
  
  
  private 
  
  def find_group
    @group = Group.find(params[:group]) if params[:group]
  end
  
  def find_video
    @video =  Video.find(params[:id])
    @shared_groups = @video.shares_to_groups.collect(&:shared_to)
  end
  
  
end
