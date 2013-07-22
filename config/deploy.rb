require 'capsum/typical'
require 'capsum/sidekiq'

set :application, "prelude-client"
set :repository, ".git"

set :shared, %w{
  allow
  pcaps
  config/database.yml
  config/settings.local.yml
}

def run(cmd, options={}, &block)
  user = options.delete(:su)
  cmd = "su - #{user} -c " + cmd.shellescape if user
  super(cmd, options, &block)
end