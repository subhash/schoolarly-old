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

include IceCube

class Event < ActiveRecord::Base
  
  named_scope :between, lambda { |start_date, end_date| { :conditions => ['start_date >= ? and end_date <= ?', start_date, end_date], :order => 'start_date desc, start_time desc' } }  
  
  acts_as_commentable
  acts_as_shareable
  
  def start_datetime
    start_offset = {:hours => self.start_time.hour, :minutes => self.start_time.min, :seconds => self.start_time.sec}
    self.start_date.to_time.advance(start_offset)
  end
  
  def end_datetime
    end_offset = {:hours => self.end_time.hour, :minutes => self.end_time.min, :seconds => self.end_time.sec}
    self.end_date.to_time.advance(end_offset)
  end
  
  def recurrent?
    ! (self.recurrence.blank? || self.recurrence == 'once')
  end
  
  def recurrences
    if self.recurrent? 
      schedule = Schedule.new(self.start_datetime)
      recurrence = Rule.send(self.recurrence)
      recurrence.until(self.until)
      schedule.add_recurrence_rule(recurrence)
      schedule.all_occurrences
    end
  end
  
  
end
