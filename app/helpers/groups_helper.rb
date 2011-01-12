module GroupsHelper
  def ancestor_path_for(group)
    s = []
    group.ancestors.reverse.each{|a| s << "#{link_to(a.name, group_path(a))}>"}
    s.join
  end
  
  
end
