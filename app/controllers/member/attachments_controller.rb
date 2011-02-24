class Member::AttachmentsController < Member::BaseController
  
  before_filter :find_group, :except => [:index, :show]
  
  def new
    @attachment = Attachment.new
  end
  
  def create
    @attachment = Attachment.new(params[:attachment])
    @attachment.user = current_user
    @attachment.title = @attachment.doc.original_filename if @attachment.title.blank?
    respond_to do |wants|
      if @attachment.save
        @attachment.upload_to_crocodoc
        @group.share(current_user, @attachment.class.to_s, @attachment.id) if @group
        wants.html do
          flash[:ok] = I18n.t('attachments.member.add_success')
          redirect_back_or_default member_attachments_path(@attachment)
        end
      else
        wants.html do
          flash[:error] = I18n.t('attachments.member.add_failure')
          render :new
        end
      end      
    end
  end
  
  def update
    @attachment = Attachment.find(params[:id])
    respond_to do |wants|
      if @attachment.update_attributes(params[:attachment])
        wants.html do
          flash[:ok]=I18n.t('tog_conversatio.member.posts.post_updated')
          redirect_back_or_default attachment_path(@attachment)
        end
      else
        wants.html do
          flash.now[:error]='Failed to update the document.'
          render :action => :edit
        end
      end
    end
  end
  
  
  def edit
    @attachment = Attachment.find params[:id]
  end
  
  def index
    @attachments = current_user.attachments
  end
  
  def show
    @attachment = Attachment.find params[:id]
  end
  
  private  
  def find_group
    @group = Group.find(params[:group]) if params[:group]
  end
  
end
