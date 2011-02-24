class Attachment < ActiveRecord::Base
  acts_as_commentable
  has_attached_file :doc, 
    :storage => :s3, 
    :s3_credentials => "#{RAILS_ROOT}/config/s3.yml", 
    :path => "/system/:class/:attachment/:id/:style_:basename.:extension"
  
  belongs_to :user
  
  # XXXX HACK HACK HACK
  OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE
  
  # XXXX HACK HACK HACK
  module Net
    class HTTP
      alias old_initialize initialize
      
      def initialize(*args)
        old_initialize(*args)
        @read_timeout = 3*60     # 3 minutes
      end
    end
  end
  
  def upload_to_crocodoc
    url = "https://crocodoc.com/api/v1/document/upload?token=vJK2p8cYFP1Xo0CUmweD"
    url += "&url=#{self.doc.url}"
    puts url
    open url do |f|
      puts 'crocodoc responded with - '+f.string
      results = ActiveSupport::JSON.decode(f.string)
      results.each do |k,v|
        case k
        when 'error'
          puts "error in uploading to crocodoc - #{v} "
          return false
        when 'shortId'
          self.shortId = v
        when 'uuid'
          self.uuid = v
        else
          puts "unknown results from crocodoc - #{k}=#{v}"
        end
      end
    end
    self.save
  end
  
end
