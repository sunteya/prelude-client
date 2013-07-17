require 'capsum/typical'
require 'capsum/sidekiq'

set :application, "prelude-client"
# set :repository, ".git"

set :shared, %w{
  allow
  pcaps
  config/database.yml
  config/settings.local.yml
}
