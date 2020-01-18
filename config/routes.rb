Rails.application.routes.draw do
  resources :transfers, only: :index
  get '/transfers/:to(/:symbol(/:per_page(/:page))).json', to: 'transfers#index', as: :inline_transfers, constraints: { to: /([^\/])+/ }
  
  resources :issues, only: :index
  get '/issues/:to(/:symbol(/:per_page(/:page))).json', to: 'issues#index', as: :inline_issues, constraints: { to: /([^\/])+/ }
  
  resources :transactions, only: %i(index show)
  get '@:account(/:symbol)', to: 'transactions#index', as: :account_home, constraints: { account: /([^\/])+/ }
  get '/open_orders/@:account(/:symbol)', to: 'transactions#open_orders', as: :open_orders, constraints: { account: /([^\/])+/ }
  get '/tx/:trx_id', to: 'transactions#show', as: :tx
  
  resources :tokens, only: %i(index show) do
    resources :richlist, only: %i(index)
  end
  
  resources :nfts, only: %i(index show)
  
  resources :blocks, only: %i(show)
  get '/b/:block_num', to: 'blocks#show', as: :b
  
  resources :contracts, only: %i(index show)
  get '/contracts/:a_trx_id/:b_trx_id', to: 'contracts#diff', as: :contract_diff

  resources :checkpoints, only: %i(index)
  
  get '/.well-known/healthcheck', to: 'health#index', format: :json
  
  root to: 'dashboard#index'
end
