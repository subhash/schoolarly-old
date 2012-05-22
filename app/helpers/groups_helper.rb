module GroupsHelper
  def ancestor_path_for(group)
    #    have to take group.parent & cannot do group.ancestors 'coz group is a New group(not saved into db)
    return unless group.parent
    s = group.parent.self_and_ancestors.reverse.map{|g| link_to(g.name, (current_user ? member_group_path(g) : group_path(g))) }.join " > " 
    return s + " > "
  end
  
  def path_for(group)
    s = group.self_and_ancestors.reverse.map{|g| link_to(g.name, (current_user ? member_group_path(g) : group_path(g))) }.join " > "
  end
  
  def default_blog_for(group)
    #    current_user.default_notebook_for(group)
    current_user.default_notebook
  end
  
end
