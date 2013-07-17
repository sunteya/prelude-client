Sidekiq.configure_server do |config|
  config.redis = { :namespace => 'prelude' }
  config.poll_interval = 1
  config.failures_default_mode = :exhausted
end

Sidekiq.configure_client do |config|
  config.redis = { :namespace => 'prelude' }
end