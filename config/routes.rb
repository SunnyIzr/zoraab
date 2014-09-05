Zoraab::Application.routes.draw do
  root 'welcome#index'

  resources :subs, only: [:new, :create, :show, :index] do
    resources :orders, only:[:new, :create]
  end
  resources :orders, only: [:show, :index, :destroy]
  
  resources :invoices

  resources :batches, only: [:new, :create, :show, :index]
  resources :braintree_recs, only: [:create]

  resources :quickbooks do
    collection do
      get :authenticate
      get :oauth_callback
    end
  end
  
  get '/braintree-recs/trans-rec/:id' => 'braintree_recs#trans_rec', as: :trans_rec 
  get '/braintree-recs/disb-rec/:id' => 'braintree_recs#disb_rec', as: :disb_rec
  post '/braintree-recs/reconcile/:id' => 'braintree_recs#reconcile'
  get 'braintree-rec/upload/:id' => 'braintree_recs#upload', as: :upload_sub_orders
  post '/braintree-recs/disb-rec/:id' => 'braintree_recs#mark_items_as_recd'
  get '/braintree-recs/upload' => 'braintree_recs#upload_braintree'
  post '/shopify-orders' => 'orders#shopify_orders'
  post '/upload-order-to-qb' => 'quickbooks#upload_to_shopify'
  get '/upload-shopify-orders' => 'quickbooks#upload_shopify_orders'
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
  post '/send-to-shipstation'=> 'orders#send_to_shipstation'
  get '/quickbooks' => 'quickbooks#index'
  get '/subs-upcoming/' => 'subs#index_upcoming'
  get '/:sub_id/check-dupe/:sku' => 'subs#check_dupe'
  post '/send-to-shopify/:order_id' => 'orders#send_to_shopify'
  post '/refresh_subs' => 'subs#refresh_subs'
  patch '/:sub_id/change_prefs' => 'subs#change_prefs', as: :change_prefs
  post '/subs/add_line_item' => 'orders#add_line_item', as: :add_line_item
  get '/outstanding_renewals/:id/destroy' => 'welcome#destroy_oren', as: :destroy_outstanding_renewal
  get '/outstanding_signups/:id/destroy' => 'welcome#destroy_osign', as: :destroy_outstanding_signup
  post '/check-product' => 'invoices#check_product'
  get '/invoices/:id/send-to-qb' => 'invoices#save_to_qb', as: :save_invoice_to_qb
  post '/check-all-products' => 'invoices#check_all_products'
  post '/create-all-products' => 'invoices#create_all_products'
  get '/vendors' => 'invoices#vendors'

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
