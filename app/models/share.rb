class Share < ActiveRecord::Base
  belongs_to :shareable, :polymorphic => true
  belongs_to :shared_to, :polymorphic => true
  
  
  named_scope :shares_to_groups_of_object, lambda{|object|
    {:conditions => {:shareable_type => ActiveRecord::Base.send(:class_name_of_active_record_descendant, object.class).to_s, 
    :shareable_id => object.id, 
    :shared_to_type =>'Group'}
    }
  }
end