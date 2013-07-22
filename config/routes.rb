require 'sidekiq/web'
PreludeClient::Application.routes.draw do

  devise_for :users
  authenticate :user do
    mount Sidekiq::Web => '/sidekiq'
    root to: "main#root"
  end

  match '/grant' => "main#grant", via: [ :get, :post ]
end
