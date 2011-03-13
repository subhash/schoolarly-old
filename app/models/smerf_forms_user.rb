class SmerfFormsUser < ActiveRecord::Base
  
  after_create :create_user
  
  private
  
  def create_user    
    user = User.new(:email => self.responses['q_email'])
    user.login ||= user.email if Tog::Config["plugins.tog_user.email_as_login"]
    user.profile = Profile.new(:first_name => self.responses['q_name'])
    if user.invite_over_email
      membership = Membership.new
      membership.user = user
      membership.group = School.first.group
      membership.save
      # send email
    end    
  end
  
end