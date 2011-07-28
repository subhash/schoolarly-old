class Membership < ActiveRecord::Base
  
  before_destroy :destroy_empty_notebooks
  
  def create_default_notebook   
    bs = user.bloggerships.new
    bs.build_blog(:title => group.display_name, :description => (Tog::Config["plugins.schoolarly.group.notebook.default"]+" "+group.path), :author => user)
    bs.save
  end
  
  def destroy_empty_notebooks
    blog = user.default_notebook_for(group)
    blog.destroy if blog and blog.posts.empty? 
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
