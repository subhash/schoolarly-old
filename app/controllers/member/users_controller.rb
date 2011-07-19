class Member::UsersController < Member::BaseController   
  
  before_filter :ban_access, :except => [:my_account, :change_password]
  
  
end