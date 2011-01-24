class Member::ProfilesController < Member::BaseController
  
  def search
    puts 'sources - '+Tog::Search.sources.inspect
    @matches = Tog::Search.search(params[:q], {:only => ["Profile"]}, {:page => '1'})
    respond_to do |format|
      format.html 
      format.xml  { render :xml => @matches }
      format.js {
        profiles = @matches.collect { |m| {:id => m.id, :name => m.full_name}}
        render :text => profiles.to_json
      }
    end
  end
end