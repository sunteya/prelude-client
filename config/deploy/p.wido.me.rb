set :deploy_to, "/var/www/wido.p/#{application}"

set :rails_env, "production"
set :user, "root"
server "p.wido.me", :app, :web, :db #, whenever: true, primary: true
default_environment["http_proxy"] = default_environment["https_proxy"] = "http://localhost:8118"