class SmerfFormsUser < ActiveRecord::Base
  
  before_create :create_user
  
  private
  
  def create_user
#    puts 'creating user as well'
#    user = User.new(:email => self.responses['q_email'])
#    user.login ||= user.email if Tog::Config["plugins.tog_user.email_as_login"]
#    user.profile = Profile.new(:first_name => self.responses['q_name'])
#    user.smerf_forms_user = self
    user = self.user
    if user.invite_over_email      
      membership = Membership.new
      membership.user = user
      school = School.all.find {|s| s.form_code == self.smerf_form.code}
      membership.group = school.group      
      # send email
      membership.save
    else
      return false
    end    
  end
  
end