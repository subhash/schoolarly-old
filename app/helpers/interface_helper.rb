module InterfaceHelper
  
  def columns_distribution
    @columns_distribution || "col_70_30"
  end
  
  def nav_link_to(tab)
    contents = ""
    if tab.include_url?(request.request_uri)
      contents << content_tag(:li, %{#{link_to I18n.t(tab.key), tab.url}#{sub_nav_links_to(tab.items)}}, :class=>"on")
    else
      contents << content_tag(:li, link_to(I18n.t(tab.key), tab.url))
    end
    if (I18n.t(tab.key) == "Messages" && current_user && current_user.inbox.messages.unread.size > 0)
      
      contents << link_to(current_user.inbox.messages.unread.size, tab.url, :class => "message-bubble")
    end
    return contents
  end
  
end