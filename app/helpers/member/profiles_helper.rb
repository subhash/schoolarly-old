module Member::ProfilesHelper
  
  def smerf_group_name(group)    
    content_tag(:legend, group.name) unless group.name.blank?
  end
  
  def smerf_group_question(question, level = 1, view = false)
    contents = ""
    # Format question header 
    contents += content_tag(:div, content_tag(:p, question.header), 
      :class => "smerfQuestionHeader") if (question.header and !question.header.blank?) 
    # Format question  
    contents += label_tag("responses[#{question.code}]", question.question, 
      :class => (level <= 1) ? "smerfQuestion" : "smerfSubquestion") if (question.question and !question.question.blank?) 
    # Format error
    contents += content_tag(:div, 
    content_tag(:p, "#{image_tag("smerf_error.gif", :alt => "Error")} #{@errors["#{question.item_id}"]["msg"]}"), 
      :class => "smerfQuestionError") if (@errors and @errors.has_key?("#{question.item_id}"))    
    # Format help   
    contents += content_tag(:div, 
    content_tag(:p, "#{image_tag("smerf_help.gif", :alt => "Help")} #{question.help}"), 
      :class => "smerfInstruction") if (!question.help.blank?)    
    
    # Check the type and format appropriatly
    case question.type
      when 'multiplechoice'
      contents += get_multiplechoice(question, level)
      when 'textbox'
      contents += get_textbox(question)
      when 'textfield'
      contents += get_textfield(question, view)
      when 'singlechoice'
      contents += get_singlechoice(question, level)
      when 'selectionbox'
      contents += get_selectionbox(question, level)
    else  
      raise("Unknown question type for question: #{question.question}")
    end
    # Draw a line to indicate the end of the question if level 1, 
    # i.e. not an answer sub question
    contents += content_tag(:div, "", :class => "questionbox") if (!contents.blank? and level <= 1)
    return content_tag(:p, contents)   
  end
  
  def get_textfield(question, view_only = false)
    # Get the user input if available
    user_answer = nil
    if (@responses and !@responses.empty?() and 
      @responses.has_key?("#{question.code}"))
      user_answer = @responses["#{question.code}"]
    end
    unless view_only
      contents = text_field_tag("responses[#{question.code}]", 
      # Set value to user responses if available
       (user_answer and !user_answer.blank?())? user_answer : nil, 
        :size => (!question.textfield_size.blank?) ? question.textfield_size : "30")
    else
      contents = content_tag(:div, content_tag(:em, user_answer), :class => "text") if user_answer
    end
    contents
  end
  
end