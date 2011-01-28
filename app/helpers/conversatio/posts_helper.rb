module Conversatio
  module PostsHelper

    def i_am_the_author_of?(post)
      post.user == current_user
    end
    
  end
end
