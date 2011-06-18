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
  acts_as_shareable
  has_many :shares_to_groups, :class_name => 'Share', :as => :shareable, :conditions => {:shared_to_type => 'Group'}
  has_attached_file :doc, Tog::Plugins.storage_options   
  
  validates_presence_of :body, :unless => Proc.new{|p| p.doc.file? }
  
  validates_attachment_presence :doc, :if => Proc.new{|p| p.body.blank?}
  
  before_validation :adjust_body
  
  
  def to_crocodoc(use_body = false)
    url = "https://crocodoc.com/api/v1/document/upload"
    puts "self.doc.file? #{self.doc.file?}"
    if(self.doc.file?)
      file = self.doc.to_file
    elsif use_body
      file = StringIO.new(self.body)
      puts "file - #{file}"
      def file.path
        return "foo.doc"
      end
      
      def file.original_filename
        return "foo.doc"
      end
      
      def file.content_type
        return "text/html"
      end
    end
    puts 'file - '+file.inspect
    puts 'file path - '+file.path
    begin
      response = RestClient.post(url, :token => 'vJK2p8cYFP1Xo0CUmweD', :file => file, :private => true, :multipart => true)
      puts "Response - #{response}"
      results = ActiveSupport::JSON.decode(response.to_s)
      raise "Error while uploading to crocodoc - #{results["error"]}" if results.include? "error"
      self.shortId = results['shortId']
      self.uuid = results['uuid']
    rescue Exception => e
      puts e.inspect
    end
  end
  
  def from_crocodoc(user_name, editable = false)
    url = "https://crocodoc.com/api/v1/session/get"
    response = RestClient.get(url, :params => {:token => 'vJK2p8cYFP1Xo0CUmweD', :uuid => self.uuid, :name => CGI::escape(user_name), :editable => editable, :multipart => true})
    puts "Response - #{response}"                    
    results = ActiveSupport::JSON.decode(response.to_s)
    raise "Error while getting session from crocodoc - #{results["error"]}" if results.include? "error"
    return results['sessionId'] if results.include? 'sessionId'
    puts 'unexpected results - '+results.inspect
  end
  
  private
  
  def adjust_body
    puts 'adjust body'
    self.body = self.title if self.doc.file?
  end
  
end

class InlineHTML
  
end
