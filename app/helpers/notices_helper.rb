module NoticesHelper  
  def i_am_the_author_of?(obj)
    obj.user == current_user
  end
  
  def truncate_to_words(text, opts = {})
    opts = {:words => 100, :omission => "..."}.merge(opts)
    words = opts[:words]
    omission = opts[:omission]
    text.split[0..(words-1)].join(" ") + (text.split.size > words ? " " + omission : "")
  end
  
end
