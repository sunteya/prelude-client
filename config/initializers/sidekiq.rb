Sidekiq.configure_server do |config|
  config.redis = { :namespace => 'prelude' }
  config.poll_interval = 1
end

Sidekiq.configure_client do |config|
  config.redis = { :namespace => 'prelude' }
end