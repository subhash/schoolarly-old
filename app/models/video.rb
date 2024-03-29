class Video < ActiveRecord::Base
  require 'uri'
  include HTTParty
  
  belongs_to :user
  acts_as_commentable
  acts_as_shareable
    
  validates_presence_of :title
  
  validates_presence_of :link, :if => Proc.new{|p| p.token.blank? }
  validates_presence_of :token, :if => Proc.new{|p| p.link.blank? }
  validate :valid_url?, :if => Proc.new {|p| p.token.blank?}
    
  has_many :shares_to_groups, :class_name => 'Share', :as => :shareable, :conditions => {:shared_to_type => 'Group'}, :include => {:shared_to => [:parent] }
    
  def embed(width = "640", height = "390")
    embed_code = "<iframe src='#{url}' width='#{width}' height='#{height}' frameborder='0' allowfullscreen></iframe>"
  end
  
  def url
    url = nil
    case base_uri
      when "www.youtube.com"
      url = "http://www.youtube.com/embed/#{video_id}?autoplay=1&rel=0" 
      when "www.vimeo.com"
      url = "http://player.vimeo.com/video/" + video_id
    end
    
    url
  end
  
  def thumbnail
    url = nil
    case base_uri
      when "www.youtube.com" 
      url = "http://img.youtube.com/vi/" + video_id + "/2.jpg"
      when "www.vimeo.com"
      url = thumbnail_path( image_base_uri, video_id )
    end
    url  
  end
  
  def self.youtube_client
    YouTubeIt::Client.new(SCHOOLARLY)
  end
  
  protected 
  
  def valid_url?
    errors.add(:link, I18n.t('videos.model.url.invalid')) if url.nil?
    errors.add(:link, I18n.t('videos.model.url.invalid')) if video_id.nil?
  end
  
  
  # Video Paths:
  #   http://www.youtube.com/watch?v=Gqraan6sBjk
  #   http://www.vimeo.com/21618919
  # Thumbnail Paths:
  #   http://img.youtube.com/vi/Gqraan6sBjk/2.jpg
  private
    
  SCHOOLARLY = {:username => 'schoolarly@gmail.com', :password => 'myword178', :dev_key => 'AI39si5FVyA7IBPF1yOlAUkVTCTPrFcbnJizPAPlGEmpT9BoLn1ddLbRyOvLMLQj_0pOnMZnIrQ3E-ZQ-VMD0to6henOfL8YUw'}
    
  def image_base_uri
    image_base_uri = nil
    case base_uri
      when "www.youtube.com"
      image_base_uri = "http://img.youtube.com/vi/"
      when "www.vimeo.com"
      image_base_uri = "http://vimeo.com/api/v2/video/"
    end
    
    image_base_uri
  end
  
  def thumbnail_path(base_uri, videoid = nil, format = 'xml')
    path = nil
    
    return path if base_uri.nil?
    
    xml     = HTTParty.get( base_uri + ( videoid.nil? ? video_id : videoid ) + format.insert(0, '.') )
    values  = xml.parsed_response.values_at("videos").first.fetch('video')
    if values["user_portrait_medium"].include?('100')
      path  = values["user_portrait_medium"]
    else values["user_portrait_large"].include?('100')
      path = values["user_portrait_large"]
    end
    
    path
  end
  
  def base_uri
    @uri ||= parse_it
    
    case @uri.host
      when "www.youtube.com","youtube.com", "youtu.be"
      return "www.youtube.com"
      when "www.vimeo.com", "vimeo.com"
      return "www.vimeo.com"
    else
      return nil
    end
  end
  
  def video_id
    video_id = nil
    case base_uri
      when "www.youtube.com"
      if @uri.query
        video_id = CGI::parse(@uri.query)["v"].first
      else
        video_id = link.split("/").last
      end
      when "www.vimeo.com"
      video_id = @uri.path.delete('/')
    end
    video_id
  end
  
  def parse_it
    @uri = URI.parse(self.link)
  end
  
end
