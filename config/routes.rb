Agsexplorer::Application.routes.draw do

  match 'home' => 'home#index'

  # blocks
  get ':network/block/:hash' => 'blocks#show_by_hash', as: :block
  get ':network/block-height/:height' => 'blocks#show_by_height', as: :height_block

  # tx
  get ':network/tx/:hash' => 'tx#show_by_hash', as: :tx
  get ':network/tx-index/:tx_id(/:idx)' => 'tx#show_by_id', as: :index_tx
  # address
  get ':network/address/:address' => 'addresses#show', as: :address

  # fetch ticker
  get "proxy/:market/ticker/:pair" => 'proxy#ticker', as: :ticker

  match 'balances/:address' => 'balances#show', as: :balance
  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
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

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  root :to => 'home#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
