class Video < ActiveRecord::Base
  require 'uri'
  include HTTParty
  
  belongs_to :user
  acts_as_commentable
  acts_as_shareable
  
  validates_presence_of :title, :link
  
  has_many :shares_to_groups, :class_name => 'Share', :as => :shareable, :conditions => {:shared_to_type => 'Group'}
  
  #  validates :link, :presence => true, :domain => true
  
  
  
  def embed(width = "640", height = "390")
    embed_code = nil
    case base_uri
      when "www.youtube.com", "youtube.com"
      embed_code = "<object width='#{width}' height='#{height}'>" +
              "<param name='movie' value='#{url}'></param>" +
              "<param name='allowFullScreen' value='false'></param>" +
              "<param name='allowscriptaccess' value='always'></param>" +
              "<embed src='#{url}' type='application/x-shockwave-flash' allowscriptaccess='always' allowfullscreen='false' 
                  width='#{width}' height='#{height}'> </embed>" +
            "</object>"
      when "www.vimeo.com", "vimeo.com"
      embed_code = "<iframe src='#{url}' width='#{width}' height='#{height}' frameborder='0'></iframe>"
    end
    
    embed_code
  end
  
  def url
    url = nil
    case base_uri
      when "www.youtube.com","youtube.com"
      url = "http://www.youtube.com/v/" + video_id + "&amp;hl=en_US&amp;fs=1"
      when "www.vimeo.com", "vimeo.com"
      url = "http://player.vimeo.com/video/" + video_id
    end
    
    url
  end
  
  def thumbnail
    url = nil
    case base_uri
      when "www.youtube.com","youtube.com"  
      url = "http://img.youtube.com/vi/" + video_id + "/2.jpg"
      when "www.vimeo.com", "vimeo.com"
      url = thumbnail_path( image_base_uri, video_id )
    end
    
    url  
  end
  
  # Video Paths:
  #   http://www.youtube.com/watch?v=Gqraan6sBjk
  #   http://www.vimeo.com/21618919
  # Thumbnail Paths:
  #   http://img.youtube.com/vi/Gqraan6sBjk/2.jpg
  private
  def image_base_uri
    image_base_uri = nil
    case base_uri
      when "www.youtube.com","youtube.com"
      image_base_uri = "http://img.youtube.com/vi/"
      when "www.vimeo.com", "vimeo.com"
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
    
    @uri.host
  end
  
  def video_id
    video_id = nil
    case base_uri
      when "www.youtube.com","youtube.com"
      video_id = @uri.query.split('=')[1].slice(0, 11)
      when "www.vimeo.com", "vimeo.com"
      video_id = @uri.path.delete('/')
    end
    
    video_id
  end
  
  def parse_it
    @uri = URI.parse( link )
  end
  
  
  
  
end
