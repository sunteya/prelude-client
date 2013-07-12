require "capsum/typical"

set :application, "prelude-client"
set :repository, ".git"

set :shared, %w{
  config/database.yml
}
