namespace :app do
  desc "cleanup app expired data"
  task cleanup: :environment do
    SquidLogAnalysisState.where("updated_at < ?", 1.days.ago).destroy_all

    begin
      result = Traffic.where(synchronized: true).where("updated_at < ?", 3.days.ago).limit(1000).destroy_all
    end while result.any?
  end
end

