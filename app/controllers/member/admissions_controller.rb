class Member::AdmissionsController < Member::BaseController
  
  ACCOUNT = 'schoolarly'
  API_KEY = '689A-NOT2-354N-2JOQ'
  FORM_ID = 'w7x3z9'
  
  before_filter :find_group
  
  def index    
    wufoo = WuParty.new(ACCOUNT, API_KEY)
    form = wufoo.form(FORM_ID)
    @entries = form.entries
  end
  
  def show
    wufoo = WuParty.new(ACCOUNT, API_KEY)
    form = wufoo.form(FORM_ID)
    puts params[:id].inspect
    @fields = form.entries.find {|f| f["EntryId"] == params[:id]}
    puts @fields.inspect
  end
  
  private
  def find_group
    @group = Group.find(params[:group_id])
  end 
  
end