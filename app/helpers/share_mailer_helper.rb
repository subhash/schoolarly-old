module ShareMailerHelper
  def name_or_title(object)    
    return object.name if object.respond_to? :name
    return object.title if object.respond_to? :title
  end
end