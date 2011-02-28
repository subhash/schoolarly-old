class AttachmentsController < ApplicationController
  
  before_filter :find_group
  
  def show
    @attachment = Attachment.find(params[:id])
    @shared_groups = @attachment.shares_to_groups.collect(&:shared_to)
  end
  
  
  private
  def find_group
    @group = Group.find(params[:group]) if params[:group]
  end
  
end
