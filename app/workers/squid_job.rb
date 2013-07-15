class SquidJob
  include Sidekiq::Worker
  sidekiq_options queue: :squid
  # sidekiq_options unique: true, unique_job_expiration: 1
  
  def perform
    squid_config_path = Project.settings.squid_config
    squid_bin = Project.settings.squid_bin

    origin_squid_config = File.read(squid_config_path)
    users = User.available.order('email')
    content = users.map { |u| "http_port #{u.binding_port}" }.join("\n")

    new_squid_config = self.class.replace(origin_squid_config, "# ====== PRELUDE START ======", "# ====== PRELUDE END ======", content)

    if origin_squid_config != new_squid_config
      File.open(squid_config_path, 'w') { |f| f << new_squid_config }
      `#{squid_bin} -k reconfigure`
    end
  end

  def self.replace(source, mark_line_start, mark_line_end, content)
    target = []
    if (mark_start_pos = source.index(mark_line_start))
      target << source[0, mark_start_pos]
    end

    target << mark_line_start << "\n"
    target << content << "\n"
    target << mark_line_end << "\n"

    if (mark_end_pos = source.index(mark_line_end))
      target << source[mark_end_pos + mark_line_end.length + 1, source.length]
    end

    target.join
  end
  
end