class Conversatio::PostsController < ApplicationController
  
  before_filter :find_group
  
  
  private
  def find_group
    puts "in find group"
    @group = Group.find(params[:group]) if params[:group]
  end
  
end
