# == Schema Information
# Schema version: 1
#
# Table name: blogs
#
#  id         :integer(11)   not null, primary key
#  blog_id    :integer(11)
#  title      :string(255)
#  body       :text
#  user_id    :integer(11)
#  created_at :datetime
#  updated_at :datetime
#

class Post < ActiveRecord::Base
  has_many :shares_to_groups, :class_name => 'Share', :as => :shareable, :conditions => {:shared_to_type => 'Group'}
  has_attached_file :doc, Tog::Plugins.storage_options   
  
  validates_presence_of :body, :unless => Proc.new{|p| p.doc.file?}
  
  validates_attachment_presence :doc, :if => Proc.new{|p| p.body.blank?}
  
  
  def to_crocodoc
    url = "https://crocodoc.com/api/v1/document/upload"
    response = RestClient.post(url, :token => 'vJK2p8cYFP1Xo0CUmweD', :file => self.doc.to_file, :private => true)
    puts "Response - #{response}"
    results = ActiveSupport::JSON.decode(response.to_s)
    raise "Error while uploading to crocodoc - #{results["error"]}" if results.include? "error"
    self.shortId = results['shortId']
    self.uuid = results['uuid']
  end
  
  def from_crocodoc(user_name, editable = false)
    url = "https://crocodoc.com/api/v1/session/get"
    response = RestClient.get(url, :params => {:token => 'vJK2p8cYFP1Xo0CUmweD', :uuid => self.uuid, :name => CGI::escape(user_name), :editable => editable})
    puts "Response - #{response}"                    
    results = ActiveSupport::JSON.decode(response.to_s)
    raise "Error while getting session from crocodoc - #{results["error"]}" if results.include? "error"
    return results['sessionId'] if results.include? 'sessionId'
    puts 'unexpected results - '+results.inspect
  end
  
end
