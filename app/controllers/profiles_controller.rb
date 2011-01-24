class ProfilesController < ApplicationController

  def show
    @profile = Profile.find(params[:id])
    store_location
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @profile }
    end
  end
  

end
