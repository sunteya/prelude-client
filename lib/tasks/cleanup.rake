namespace :app do
  desc "cleanup app expired data"
  task cleanup: :environment do
    SquidLogAnalysisState.where("updated_at < ?", 3.days.ago).destroy_all
    Traffic.where(synchronized: true).where("updated_at < ?", 3.days.ago).destroy_all
  end
end