class Project < Fume::Settable::Base
  yaml_provider Rails.root.join("config/settings.local.yml")
end