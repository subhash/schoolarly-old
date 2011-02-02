class Member::AttachmentsController < ApplicationController
  
  before_filter :find_group
  
  def new
    @attachment = Attachment.new
  end
  
  def create
    @attachment = Attachment.new(params[:attachment])
    @attachment.user = current_user
    respond_to do |wants|
      if @attachment.save
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
  
  private 
  
  def find_group
    @group = Group.find(params[:group]) if params[:group]
  end
  
end