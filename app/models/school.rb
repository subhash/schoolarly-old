class School < ActiveRecord::Base
  
  has_one :group, :as => :network
  
  #  has_many :sub_groups, :through => :group
  
  has_many :klasses,  :through => :group,
                              :conditions => ['groups.network_type = ?', 'Klass']
  
  named_scope :active, :include => :group, :conditions => ['groups.state = ?', 'active']
  
  def form_code
    group.name.parameterize[0, 20]
  end
  
end
