module ProfilesHelper

  def icon_for_profile(profile, size, options={})
     options.merge!(:class => profile.user.state)
    if profile.icon?
      photo_url = profile.icon.url(size)
      options.merge!(:alt => I18n.t("tog_social.profiles.helper.photo_for_user", :name => profile.full_name))
      return image_tag(photo_url, options) if photo_url
    else
      return image_tag("/tog_social/images/#{config["plugins.tog_social.profile.image.default"]}" , options)
    end
  end

end
