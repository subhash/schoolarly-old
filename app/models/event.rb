# == Schema Information
# Schema version: 20100622215122
#
# Table name: events
#
#  id                :integer         not null, primary key
#  title             :string(255)
#  description       :text
#  start_date        :date
#  end_date          :date
#  start_time        :time
#  end_time          :time
#  url               :string(255)
#  venue             :string(255)
#  venue_link        :string(255)
#  user_id           :integer
#  created_at        :datetime
#  updated_at        :datetime
#  capacity          :integer         default(-1)
#  venue_address     :string(255)
#  site_wide         :boolean
#  icon_file_name    :string(255)
#  icon_content_type :string(255)
#  icon_file_size    :integer
#  icon_updated_at   :datetime
#  moderated         :boolean
#
class Event < ActiveRecord::Base

  named_scope :between, lambda { |start_date, end_date| { :conditions => ['start_date >= ? and end_date <= ?', start_date, end_date], :order => 'start_date desc, start_time desc' } }  
  
  acts_as_commentable
end
