Rails.application.routes.draw do
  root 'incidents#index'
  resources :incidents, only: [:index, :create] do
    member do
      patch :resolve
    end
  end
  post '/slack/commands', to: 'slack#commands'
  post '/slack/interactive', to: 'slack#interactive'
  get 'slack/oauth/redirect', to: 'slack_oauth#oauth_redirect'
  get 'slack/oauth/callback', to: 'slack_oauth#oauth_callback'
  match '*path', to: 'application#render_404', via: :all
end
