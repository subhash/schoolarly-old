class Member::ProfilesController < Member::BaseController
  
  def search
    puts "in search "+params[:q].inspect
    @matches = Tog::Search.search(params[:q], {:only => [:profiles]}, {:page => '1'})
    respond_to do |format|
      format.html 
      format.xml  { render :xml => @matches }
      format.js{
        profiles = @matches.collect { |m| {:id => m.id, :name => m.full_name}}
        render :text => profiles.to_json
      }
    end
  end
  
  def search2
    puts "search2"
  end
end