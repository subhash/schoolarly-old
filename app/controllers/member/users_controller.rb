class Member::UsersController < Member::BaseController   
  
  before_filter :ban_access, :except => []
  
  
end