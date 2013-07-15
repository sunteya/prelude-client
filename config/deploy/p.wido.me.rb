set :deploy_to, "/var/www/wido.p/#{application}"

set :rails_env, "production"
set :user, "root"
server "p.wido.me", :app, :web, :db, primary: true, whenever: true
default_environment["http_proxy"] = default_environment["https_proxy"] = "http://localhost:8118"


task :reset_permissions do
  run "chown -R www-data:www-data '#{deploy_to}'"
end
after "deploy:setup", 'reset_permissions'
after "deploy:update", 'reset_permissions'


set(:whenever_options) { { roles: fetch(:whenever_roles), only: { whenever: true }, su: 'www-data' } }
def run(cmd, options={}, &block)
  user = options.delete(:su)
  cmd = "su - #{user} -c " + cmd.shellescape if user
  super(cmd, options, &block)
end
