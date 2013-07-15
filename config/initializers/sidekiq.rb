Sidekiq.configure_server do |config|
  config.redis = { :namespace => 'prelude-client' }
end

Sidekiq.configure_client do |config|
  config.redis = { :namespace => 'prelude-client' }
end