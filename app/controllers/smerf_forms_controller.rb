class SmerfFormsController < ApplicationController
  before_filter :login_required
  
  def create
    # Make sure we have some responses
    if (params.has_key?("responses"))
      # Validate user responses
      validate_responses(params)
      # Save if no errors
      if (@errors.empty?()) 
        # Create the record 
        SmerfFormsUser.create_records(
                                      @smerfform.id, self.smerf_user_id, @responses)
        flash[:notice] = "#{@smerfform.name} submitted successfully"
        # Show the form again, allowing the user to edit responses
        redirect_back_or_default '/'
      end
    else
      flash[:notice] = "No responses found in #{@smerfform.name}, nothing saved"      
    end
  end
  
end