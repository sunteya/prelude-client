class SquidLogRotateJob
  include Sidekiq::Worker

  def perform
    squid_log_path = Project.settings.squid_log_path
    if !File.exist?(squid_log_path)
      begin
        Cocaine::CommandLine.new(Project.settings.squid_bin, "-k rotate").run
      rescue Cocaine::ExitStatusError => e
        return # squid not running, skip
      end
    end

    sleep 15 # waiting SquidLogAnalysisJob exit.
    filename = File.basename(squid_log_path)
    timestamp = Time.now.strftime("%Y%m%dT%H%M%S")
    new_filename = "#{filename}-#{timestamp}"
    SquidLogAnalysisJob.perform_async(new_filename)
  end
end