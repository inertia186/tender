Rails.application.routes.draw do
  resources :transfers, only: :index
  get '/transfers/:to(/:symbol(/:per_page(/:page))).json', to: 'transfers#index', as: :inline_transfers, constraints: { to: /([^\/])+/ }
  
  resources :issues, only: :index
  get '/issues/:to(/:symbol(/:per_page(/:page))).json', to: 'issues#index', as: :inline_issues, constraints: { to: /([^\/])+/ }
  
  resources :transactions, only: %i(index show)
  get '@:account', to: 'transactions#index', as: :account_home, constraints: { account: /([^\/])+/ }
  get '/tx/:trx_id', to: 'transactions#show', as: :tx
  
  resources :tokens, only: %i(index show)
  
  resources :blocks, only: %i(show)
  get '/b/:block_num', to: 'blocks#show', as: :b

  root to: 'dashboard#index'
end
