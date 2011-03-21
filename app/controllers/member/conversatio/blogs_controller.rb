class Member::Conversatio::BlogsController < Member::BaseController

  helper 'conversatio/blogs'

  def show
    @page = params[:page] || '1'

    @blog = Blog.find params[:id]
    @posts = @blog.posts.published.paginate :per_page => 10,
                                           :page => @page, 
                                           :order => "published_at desc"

    respond_to do |format|
      format.html
      format.atom { render(:layout => false) }
    end
  end
  
end
