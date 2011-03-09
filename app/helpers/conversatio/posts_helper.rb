module Conversatio
  module PostsHelper
    
    def i_am_the_author_of?(obj)
      obj.user == current_user
    end
    
    def truncate_to_words(text, wordcount, omission)
      text.split[0..(wordcount-1)].join(" ") + (text.split.size > wordcount ? " " + omission : "")
    end
    
  end
end
