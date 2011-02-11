module GroupsHelper
  def ancestor_path_for(group)
    s = []
    group.ancestors.reverse.each{|a| s << "#{link_to(a.name, current_user ? member_group_path(a) : group_path(a))} > "}
    s.join
  end
  
  def path_for(group)
    s = []
    group.ancestors.reverse.each{|a| s << "#{link_to(a.name, current_user ? member_group_path(a) : group_path(a))} > "}
    s.join+link_to(group.name, group_path(group))
  end
  
end
