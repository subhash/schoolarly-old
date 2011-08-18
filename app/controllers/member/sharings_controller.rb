class Member::SharingsController < Member::BaseController


  def destroy
    @sharing = @group.sharings.find params[:id]
    if @sharing && (@sharing.user == current_user || @group.moderators.include?(current_user) )
      @sharing.destroy         
      flash[:ok] = I18n.t("tog_social.sharings.member.remove_share_ok", :name => @group.name)
    else
      flash[:ok] = I18n.t("tog_social.sharings.member.remove_share_nok", :name => @group.name)      
    end
    respond_to do |format|
      format.html { redirect_back_or_default member_sharings_path }
      format.xml
    end    
  end

end
