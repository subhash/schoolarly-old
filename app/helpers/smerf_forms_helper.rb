module SmerfFormsHelper
  
  def get_textfield(question)
    # Get the user input if available
    user_answer = nil
    if (@responses and !@responses.empty?() and 
      @responses.has_key?("#{question.code}"))
      user_answer = @responses["#{question.code}"]
    end
    if @view_only
      return content_tag(:div, content_tag(:em, user_answer), :class => "text") if user_answer
    end
    contents = text_field_tag("responses[#{question.code}]", 
    # Set value to user responses if available
    if (user_answer and !user_answer.blank?())
      user_answer
    else
      nil
      end, 
        :size => (!question.textfield_size.blank?) ? question.textfield_size : "30")
      contents = content_tag(:div, content_tag(:p, contents), :class => "text")
    end
    
  end
