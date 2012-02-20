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
  acts_as_sanitized
  
  has_many :shares_to_groups, :class_name => 'Share', :as => :shareable, :conditions => {:shared_to_type => 'Group'}
  #  has_attached_file :doc, Tog::Plugins.storage_options 
  has_attached_file :doc, 
  {:styles =>  
    {:big    => Tog::Plugins.settings(:tog_picto, "photo.versions.big")}}.merge(Tog::Plugins.storage_options)
  
  before_post_process :image?
  
  validates_presence_of :body, :unless => Proc.new{|p| p.doc.file? }
  
  validates_attachment_presence :doc, :if => Proc.new{|p| p.body.blank?}
  
  before_validation :adjust_body
  
  before_save :adjust_content_type
  after_save :touch_shares
  
  def to_crocodoc!(use_body = false)
    url = "https://crocodoc.com/api/v1/document/upload"
    if(self.doc.file?)
      file = self.doc.to_file
    elsif use_body
      kit = PDFKit.new(self.body, :page_size => 'Letter')
      file = StringIO.new(kit.to_pdf)
      def file.path
        return "foo.pdf"
      end      
      def file.original_filename
        return "foo.pdf"
      end      
      def file.content_type
        return "application/pdf"
      end
    end
    begin
      response = RestClient.post(url, :token => 'vJK2p8cYFP1Xo0CUmweD', :file => file, :private => true, :multipart => true)
      puts "Response - #{response}"
      results = ActiveSupport::JSON.decode(response.to_s)
      raise "Error while uploading to crocodoc - #{results["error"]}" if results.include? "error"
      self.shortId = results['shortId']
      self.uuid = results['uuid']
      self.save
    rescue Exception => e
      puts e.inspect
    end
  end
  
  def from_crocodoc(user_name, editable = false)
    url = "https://crocodoc.com/api/v1/session/get"
    begin
      response = RestClient.get(url, :params => {:token => 'vJK2p8cYFP1Xo0CUmweD', :uuid => self.uuid, :name => CGI::escape(user_name), :editable => editable, :multipart => true})
      puts "Response - #{response}"                    
      results = ActiveSupport::JSON.decode(response.to_s)
      raise "Error while getting session from crocodoc - #{results["error"]}" if results.include? "error"
      return results['sessionId'] if results.include? 'sessionId'
      puts 'unexpected results - '+results.inspect
    rescue Exception => e
      puts e.inspect
    end      
  end
  
  def image?
    doc_content_type && doc_content_type.include?("image")
  end
  
  private
  
  def adjust_body
    self.body = self.title if self.doc.file?
  end
  
  def adjust_content_type
    self.doc.instance_write(:content_type, "application/zip") if (doc_content_type && doc_content_type.include?("zip"))
  end
  
  def touch_shares
    for share in shares
      share.touch
    end
  end 
  
end

class InlineHTML
  
end
