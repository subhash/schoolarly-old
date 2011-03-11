module Conversatio
  module PostsHelper
    
    def i_am_the_author_of?(obj)
      obj.user == current_user
    end
    
  end
end
