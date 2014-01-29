Zoraab::Application.routes.draw do
  root 'welcome#index'

  resources :subs, only: [:new, :create, :show, :index] do
    resources :orders, only:[:new, :create]
  end
  resources :orders, only: [:show]

  resources :batches, only: [:new, :create, :show, :index]

  get '/search' => 'subs#search'
  post '/search/' => 'subs#show_by_cid'
  get '/search/:cid' => 'subs#show_by_cid'
  get '/products/:sku' => 'products#info'
  get '/kitter/:sub_id' => 'subs#kitter'
  get '/next-kitter/:sub_id/:pos' => 'subs#next_kitter'
  get '/sync' => 'products#shopify_sync'
  get '/subs/:id/last-order/' => 'subs#last_order'
  post '/new-trans/' => 'chargify_hooks#new_trans'
  post '/subs-with-trans/' => 'subs#create_with_trans'
  post '/update-shopify/' => 'orders#update_shopify'


  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
