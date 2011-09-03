class Member::Picto::PhotosetsController < Member::BaseController
  
  before_filter :find_group 
  
  def show
    store_location
    @photoset = Picto::Photoset.find(params[:id])
    @shared_groups = @photoset.shares_to_groups.collect(&:shared_to)
    #    if @photoset.authorized(current_user, :read)
    #      redirect_to denied_path
    #    else
    @order = params[:order] || 'created_at'
    @page = params[:page] || '1'
    @asc = params[:asc] || 'desc'   
    @photos = @photoset.photos.paginate :page => @page,
                                    :per_page => Tog::Config["plugins.tog_social.profile.list.page.size"],
                                    :order => @order + " " + @asc      
    #    end
  end
  
  
  private  
  def find_group
    @group = Group.find(params[:group]) if params[:group]
  end
  
  
end