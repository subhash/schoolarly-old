module RubricsHelper
  
#  def i_am_the_author_of?(obj)
#    obj.user == current_user
#  end
  
  def trim(number)
    number.to_i == number ? number.to_i : number
  end
  
end
