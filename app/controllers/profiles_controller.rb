class ProfilesController < ApplicationController

  def invite_to_group
    @group = Group.find(params[:id])
    @order = params[:order] || 'created_at'
    @page = params[:page] || '1'
    @asc = params[:asc] || 'desc'  
    users = @group.parent ? (@group.parent.members - @group.users) : (User.active - @group.users)
    @profiles = users.collect(&:profile).paginate :per_page => Tog::Config["plugins.tog_social.profile.list.page.size"],
                                 :page => @page,
                                 :order => "profiles.#{@order} #{@asc}"

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @profiles }
    end
  end

end
