class Member::Picto::PhotosController < Member::BaseController
  
  before_filter :find_group
  
  def create
    @photos = current_user.photos.build(params[:photo].values)
    @common_photoset = params[:common][:photoset]
    @common_tags = params[:common][:tag_list]
    
    if @common_photoset=="0" && !params[:photoset][:title].blank?
      @photoset = current_user.owned_photosets.build(params[:photoset])
      @photoset.save!      
    else
      @photoset = current_user.owned_photosets.find @common_photoset unless @common_photoset.blank?
    end
    
    @photos.each do |p|
      if p.image?
        unless @photoset.nil?
          p.photoset = @photoset
          @photoset.main_photo = p if @photoset.main_photo.blank?
        end
        
        p.title = p.image.original_filename if p.title.blank?
        puts "photo save - #{p.save}"
        puts "photo inspect - #{p.errors.inspect}"
        @group.share(current_user, p.class.to_s, p.id) if @group
      end
    end
    
    flash[:ok] = I18n.t("tog_picto.member.photos_uploaded")
    
    unless @photoset.nil?
      @photoset.save!
      redirect_back_or_default edit_member_picto_photoset_path(@photoset)
    else 
      if @group
        redirect_back_or_default member_group_path(@group)
      else
        redirect_back_or_default member_picto_photos_path
      end
    end
  end
  
  def show
    store_location
    @size = (params[:size] || :medium).to_sym     
    @photo = Picto::Photo.find(params[:id])
    auth_photo(@photo)
    @shared_groups = @photo.shares_to_groups.collect(&:shared_to)
    respond_to do |format|
      format.js {
        render :partial => 'member/picto/photos/photo', :object => @photo
      }
      format.html{
        render :template => 'member/picto/photos/show'}
    end
  end
  
  private  
  def find_group
    @group = Group.find(params[:group]) if params[:group]
  end
  
  def auth_photo(photo)
    if photo.photoset 
      if !photo.photoset.authorized(current_user, :read)
        redirect_to denied_path
      end
    end 
  end
  
end