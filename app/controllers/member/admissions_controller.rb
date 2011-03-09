class Member::AdmissionsController < Member::BaseController
  
  ACCOUNT = 'schoolarly'
  API_KEY = '689A-NOT2-354N-2JOQ'
  FORM_ID = 'w7x3z9'
  
  before_filter :find_group
  
  before_filter :login_required, :except => [:new]
  
  def index    
    wufoo = WuParty.new(ACCOUNT, API_KEY)
    form = wufoo.form(FORM_ID)
    @entries = form.entries
    @profiles = @entries.map {|e| Profile.from_wufoo_entry(e)}
  end
  
  def show
    wufoo = WuParty.new(ACCOUNT, API_KEY)
    form = wufoo.form(FORM_ID)
    @fields = form.entries.find {|f| f["EntryId"] == params[:id]}
    @user = User.from_wufoo_entry(@fields)
  end
  
  def admit
    wufoo = WuParty.new(ACCOUNT, API_KEY)
    form = wufoo.form(FORM_ID)
    @fields = form.entries.find {|f| f["EntryId"] == params[:id]}
    @user = User.from_wufoo_entry(@fields)
    @user.login ||= @user.email if Tog::Config["plugins.tog_user.email_as_login"]
    if @user.invite_over_email
      # TODO check if you are allowed to invite
      @group.invite_and_accept(@user)
      GroupMailer.deliver_entry_notification(@group, current_user, @user)  
      #           TODO Send notification to other moderators
      redirect_back_or_default member_group_admission_path(@group, @fields["EntryId"])
    else
      puts "Failed - "+@user.errors.inspect
      render 'show'
    end    
  end
  
  private
  def find_group
    @group = Group.find(params[:group_id])
  end 
  
end