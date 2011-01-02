module GroupsHelper
  def ancestor_path_for(group)
    s = []
    group.ancestors.reverse.each{|a| s << "#{link_to(a.name, group_path(a))}>"}
    s.join
  end
  
  def path_for_group(group)
    case group.network_type
      when 'School'
      school_path(group.network)
      when  'Klass'
      member_klass_path(group.network)
    else
      group_path(group) 
    end
    
  end
end
