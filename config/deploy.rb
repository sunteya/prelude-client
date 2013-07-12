require "capsum/typical"
require 'sidekiq/capistrano

set :application, "prelude-client"
set :repository, ".git"

set :shared, %w{
  config/database.yml
}
