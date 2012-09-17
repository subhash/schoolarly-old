class Member::VideosController < Member::BaseController
  before_filter :find_group, :except => [:index, :destroy]
  before_filter :find_video, :except => [:new, :create, :index, :youtube_update]
  
  def create
    @video = Video.new(params[:video])
    @video.user = current_user
    if(params[:upload])
      @video.save(false)
      yt = Video.youtube_client
      @upload_info = yt.upload_token({:title => @video.title, :description => @video.description,
        :keywords => %w[Schoolarly], :category => 'People', :unlisted => true}, youtube_update_member_videos_url(:video_id => @video.id))
      @video.token = @upload_info[:token]
    end
    respond_to do |wants|
      wants.html do
        if @video.save
          if @video.token.blank?
            @group.share(current_user, @video.class.to_s, @video.id) if @group
            flash[:ok] = I18n.t('videos.member.add_success')
            redirect_to member_video_path(@video, :group => @group)
          else
            flash[:ok] = "Pick video file"
            render 'new'
          end
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

  def youtube_update
    @video = Video.find(params[:video_id])
    @video.link = "http://www.youtube.com/watch?v=#{params[:id]}"
    @video.token = nil
    if @video.save
      @group.share(current_user, @video.class.to_s, @video.id) if @group
      flash[:ok] = I18n.t('videos.member.add_success')
      redirect_to member_video_path(@video, :group => @group)
    else
      flash[:error] = I18n.t('videos.member.add_failure')
      render :new
    end
  end

  def show
    store_location
    @shared_groups = @video.shares_to_groups.collect(&:shared_to)
  end

  def index
    @my_videos = current_user.videos.paginate(:page => params[:page], :order => "created_at DESC")
  end

  def destroy
    respond_to do |wants|
      wants.html do
        if @video.destroy
          flash[:ok] = I18n.t('videos.member.remove_success')
          redirect_to member_videos_path
        else
          flash[:error] = I18n.t('videos.member.remove_failure')
          render :show
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
  end

end
