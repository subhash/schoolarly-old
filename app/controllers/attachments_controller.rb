class AttachmentsController < ApplicationController
  
  before_filter :find_group
  
  def show
    @attachment = Attachment.find(params[:id])
    @shared_groups = Share.shares_to_groups_of_object(@attachment).collect(&:shared_to)
  end
  
  
  private
  def find_group
    @group = Group.find(params[:group]) if params[:group]
  end
  
end
