class AggregationHierarchy < ActiveRecord::Base
  
  set_primary_key :ancestor_id, :descendant_id
  
end
