module ProfilesHelper
  
  def icon_for_profile(profile, size, options={})
    options.merge!(:class => profile.user.state)
    if !profile.icon? || profile.icon_file_name.include?('default_profile')
      return image_tag("/images/profile/#{size}_default_profile.png")
    else
      photo_url = profile.icon.url(size)
      options.merge!(:alt => I18n.t("tog_social.profiles.helper.photo_for_user", :name => profile.full_name))
      return image_tag(photo_url, options) if photo_url
    end
  end
  
  def link_to_remote_sortable_column_header(field, order_by, sort_order, name)
    if order_by == field.to_s
      sort_order = (sort_order || '').upcase == 'DESC' ? 'ASC' : 'DESC'
      arrow = (sort_order == 'ASC') ? 'down' : 'up' 
    else
      sort_order = 'ASC'
      arrow = nil
    end
    new_params = params.merge(:order_by => field.to_s, :sort_order => sort_order)
    html = link_to_remote(name, new_params, :update => 'profiles', :method => :get)
    html << image_tag("/tog_core/images/ico/arrow-#{arrow}.gif") if arrow
    html
  end
  
end
