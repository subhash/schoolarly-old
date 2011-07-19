module GroupsHelper
  def ancestor_path_for(group)
    s = []
    group.ancestors.reverse.each{|a| s << "#{link_to(a.name, current_user ? member_group_path(a) : group_path(a))} > "}
    s.join
  end
  
  def path_for(group)
    s = []
    group.ancestors.reverse.each{|a| s << "#{link_to(a.name, current_user ? member_group_path(a) : group_path(a))} > "}
    s.join+link_to(group.name, (current_user ? member_group_path(group) : group_path(group)))
  end
  
  def default_blog_for(group)
    current_user.default_notebook_for(group)
  end
  
end
