ActionController::Routing::Routes.draw do |map|
  map.resources :smerf_forms
  
  map.namespace :member do |member|
    member.resources :profiles, :collection => {:search => :get}
  end  
  
  map.routes_from_plugin 'tog_picto'
  
  map.routes_from_plugin 'tog_picto'
  
  map.routes_from_plugin 'tog_conversatio'
  
  map.routes_from_plugin 'tog_conversatio'
  
  map.routes_from_plugin 'tog_conclave'
  
  map.routes_from_plugin 'tog_conclave'
  
  map.routes_from_plugin 'tog_conclave'
  
  map.routes_from_plugin 'tog_conclave'
  
  map.routes_from_plugin 'tog_conclave'
  
  map.routes_from_plugin 'tog_mail'
  
  map.routes_from_plugin 'tog_social'
  
  map.routes_from_plugin 'tog_core'
  
  map.routes_from_plugin 'tog_user'
  
  # The priority is based upon order of creation: first created -> highest priority.
  
  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action
  
  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)
  
  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products
  
  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }
  
  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller
  
  # Sample resource route with more complex sub-resources
  #   map.resources :products do |products|
  #     products.resources :comments
  #     products.resources :sales, :collection => { :recent => :get }
  #   end
  
  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end
  
  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  # map.root :controller => "welcome"
  
  # See how all your routes lay out with "rake routes"
  
  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing or commenting them out if you're using named routes and resources.
  

  map.namespace :member do |member|
    member.resources :groups , :member => {:new_multiple => :get, :create_multiple => :post, :add_select => :get, :add => :post, :remove_select => :get, :remove => :post, :select_moderators => :get, :add_moderators => :post, :remove_moderator => :get} do |group|
      group.resources :students, :shallow => true, :member => {:new_parent => :get, :select_parent => :get, :create_parent => :post, :add_parent => :post}
      group.resources :teachers, :shallow => true
      group.resources :notices
      group.resources :reports, :shallow => true
      group.resources :aggregations, :shallow => true, :collection => {:new => :post}
    end
    member.resources :schools do |school|
      school.resources :klasses, :shallow => true, :member => {:invite => :get, :add => :post} do |klass|
        klass.resources :subjects, :shallow => true, :member => {:invite => :get, :add => :post}
      end
    end
    member.resources :rubrics
    member.resources :assignments do |assignment|
      assignment.resources :submissions, :shallow => true
      assignment.resources :grades, :shallow => true, :member => {:change_rubric => :post}
    end
    member.with_options :controller => 'groups' do |group|
      group.new_sub_group    'groups/:id/new' , :action  => 'new'
      group.new_group_with_type   'groups/new/:type', :action => 'new'
      group.group_apply   '/:id/members/:user_id/apply', :action => 'apply'
    end
  end

  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
  
  # for static files eg. /demo
  map.connect ':action', :controller => "static"
end
