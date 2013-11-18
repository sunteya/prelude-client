set :deploy_to, "/var/www/wido.p/apps/#{application}"

set :rails_env, "production"
set :user, "root"
server "p1.wido.me", :app, :web, :db, primary: true, whenever: true
default_environment["http_proxy"] = default_environment["https_proxy"] = "http://localhost:8118"


task :reset_permissions do
  run "chown -R www-data:www-data '#{deploy_to}'"
end
after "deploy:setup", 'reset_permissions'
after "deploy:create_symlink", 'reset_permissions'

before "deploy:finalize_update", "bundle:install"

set(:whenever_options) { { roles: fetch(:whenever_roles), only: { whenever: true }, su: 'www-data' } }