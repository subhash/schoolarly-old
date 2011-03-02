class Member::Conversatio::PostsController < Member::BaseController
  
  before_filter :find_group
  
  def create
    @post = Post.new params[:post]
    @post.blog = @blog
    @post.user = current_user
    @post.publish!
    
    respond_to do |wants|
      if @post.save
        @post.send("#{params[:state].to_s}!") if @post.aasm_events_for_current_state.map{|e| e.to_s}.include?("#{params[:state]}")
        wants.html do
          flash[:ok] = I18n.t('tog_conversatio.member.posts.post_created')
          if @group
            @group.share(current_user, @post.class.to_s, @post.id)
            redirect_back_or_default member_groups_path(@group)
          else            
            redirect_to member_conversatio_blog_posts_path(@blog)            
          end
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
    @group = Group.find(params[:group]) if params[:group]
  end
  
end
