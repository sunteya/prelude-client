require 'capsum/typical'
require 'capsum/sidekiq'

set :application, "prelude-client"
# set :repository, ".git"

set :shared, %w{
  config/database.yml
  config/settings.local.yml
}
