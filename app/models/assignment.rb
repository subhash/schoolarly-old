class Assignment < ActiveRecord::Base
  acts_as_commentable
  has_attached_file :doc, Tog::Plugins.storage_options   
  
  belongs_to :user
  
  has_many :shares_to_groups, :class_name => 'Share', :as => :shareable, :conditions => {:shared_to_type => 'Group'}
  
  def to_crocodoc
    url = "https://crocodoc.com/api/v1/document/upload"
    response = RestClient.post(url, :token => 'vJK2p8cYFP1Xo0CUmweD', :file => attachment.doc.to_file, :private => true)
    puts "Response - #{response}"
    results = ActiveSupport::JSON.decode(response.to_s)
    raise "Error while uploading to crocodoc - #{results["error"]}" if results.include? "error"
    attachment.shortId = results['shortId']
    attachment.uuid = results['uuid']
    attachment.save
  end
  
  def from_crocodoc(user_name)
    url = "https://crocodoc.com/api/v1/session/get"
    response = RestClient.get(url, :params => {:token => 'vJK2p8cYFP1Xo0CUmweD', :uuid => attachment.uuid, :name => CGI::escape(user_name)})
    puts "Response - #{response}"                    
    results = ActiveSupport::JSON.decode(response.to_s)
    raise "Error while getting session from crocodoc - #{results["error"]}" if results.include? "error"
    return results['sessionId'] if results.include? 'sessionId'
    puts 'unexpected results - '+results.inspect
  end
  
end
