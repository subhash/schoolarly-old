ActionController::Routing::Routes.draw do |map|
  

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
  
  
  map.resources :groups, :member => {:sharings => :post }  
  map.namespace :member do |member|
    member.resources :groups , :member => {:new_multiple => :get, :create_multiple => :post, :select => :get, :add => :post, :remove_select => :get, :remove => :post} do |group|
      group.resources :students, :shallow => true
      group.resources :teachers, :shallow => true
    end
    member.resources :schools do |school|
      school.resources :klasses, :shallow => true, :member => {:invite => :get, :add => :post} do |klass|
        klass.resources :subjects, :shallow => true, :member => {:invite => :get, :add => :post}
      end
    end
    member.resources :attachments
    member.with_options :controller => 'groups' do |group|
      group.new_sub_group    'groups/:id/new' , :action  => 'new'
      group.new_group_with_type   'groups/new/:type', :action => 'new' 
    end   
  end

  #  map.resources :schools
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
