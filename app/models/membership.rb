class Membership < ActiveRecord::Base
  
  def create_default_notebook   
    bs = user.bloggerships.new
    bs.build_blog(:title => group.name, :description => (Tog::Config["plugins.schoolarly.group.notebook.default"]+" "+group.path), :author => user)
    bs.save
  end
  
  #  def default_blog
  #    self.bloggerships.find_by_rol("default").blog
  #  end
  protected
  def do_activate
    self.activated_at = Time.now.utc
    self.activation_code = nil
    create_default_notebook
  end
  
  
end
