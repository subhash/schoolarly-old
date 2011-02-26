class Attachment < ActiveRecord::Base
  acts_as_commentable
  has_attached_file :doc, Tog::Plugins.storage_options   
  
  belongs_to :user
  
  def to_crocodoc
    url = "https://crocodoc.com/api/v1/document/upload"
    response = RestClient.post(url, :token => 'vJK2p8cYFP1Xo0CUmweD', :file => self.doc.to_file, :private => true)
    puts "Response - #{response}"
    results = ActiveSupport::JSON.decode(response.to_s)
    raise "Error while uploading to crocodoc - #{results["error"]}" if results.include? "error"
    self.shortId = results['shortId']
    self.uuid = results['uuid']
    self.save
  end
  
  def from_crocodoc(user_name)
    url = "https://crocodoc.com/api/v1/session/get"
    response = RestClient.get(url, :params => {:token => 'vJK2p8cYFP1Xo0CUmweD', :uuid => self.uuid, :name => CGI::escape(user_name)})
    puts "Response - #{response}"                    
    results = ActiveSupport::JSON.decode(response.to_s)
    raise "Error while getting session from crocodoc - #{results["error"]}" if results.include? "error"
    return results['sessionId'] if results.include? 'sessionId'
    puts 'unexpected results - '+results.inspect
  end
  
end