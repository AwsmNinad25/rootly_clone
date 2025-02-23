Rails.application.routes.draw do
  root 'incidents#index'
  resources :incidents, only: [:index, :create] do
    member do
      patch :resolve
    end
  end
  post '/slack/commands', to: 'slack#commands'
    
end
