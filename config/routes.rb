require 'sidekiq/web'
PreludeClient::Application.routes.draw do

  match '/grant' => "main#grant", via: [ :get, :post ]
  mount Sidekiq::Web => '/sidekiq'
end
