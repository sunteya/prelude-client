class SquidLogAnalysisJob
  include Sidekiq::Worker
  sidekiq_options queue: :squid_log_analysis

  def perform(new_filename)
    new_squid_log_path = File.expand_path("../#{new_filename}", squid_log_path)
    @state = SquidLogAnalysisState.where(filename: new_filename).first_or_create!

    if @state.log_file_path.blank?
      FileUtils.mv(squid_log_path, new_squid_log_path) if !File.exist?(new_squid_log_path)
      @state.update!(log_file_path: new_squid_log_path)
    end

    start_analyse_log
  end

  def squid_log_path
    Project.settings.squid_log_path
  end

  def squid_log_rotated?
    File.exist?(squid_log_path)
  end

  def start_analyse_log
    @log_file = File.open(@state.log_file_path)
    @log_file.pos = @state.position

    begin
      while true
        do_analyse_log
      end
    rescue EOFError
      if !squid_log_rotated?
        sleep 20
        retry
      end
    end
  end

  def do_analyse_log
    timeout = 30.seconds.from_now
    @cache = {}
    while Time.now < timeout
      parse_line
    end
  ensure
    store_cache_and_position
  end

  def store_cache_and_position
    ActiveRecord::Base.transaction do
      @cache.each_pair do |user_id, source_ip_map|
        source_ip_map.each_pair do |remote_ip, data|
          traffic = Traffic.where(user_id: user_id, start_at: data[:access_at], remote_ip: remote_ip).new
          traffic.synchronized = false
          traffic.incoming_bytes += data[:incoming]
          traffic.outgoing_bytes += data[:outgoing]
          traffic.save!
        end
      end

      @state.save!
    end
  end

  def parse_line
    line = @log_file.readline
    @state.position = @log_file.pos
    return if line.blank?

    regex = /([\d.]+)\s+\d+\s+([\d.]+)\s+>\s+(\d+)\s+\((\d+)\s+\+\s+(\d+)\)/
    match = line.scan(regex).first
    if match == nil
      puts "unknow squid log format: #{line}"
      return
    end

    store_to_cache(match)
  end

  def store_to_cache(match)
    access_at, source_ip, port, incoming, outgoing = *match
    access_at = Time.at(access_at.to_f)
    port      = port.to_i
    incoming  = incoming.to_i
    outgoing  = outgoing.to_i

    return if (Project.settings.squid_extra_ports || []).include?(port) # grant od local port

    bind = find_bind(port, access_at)
    if bind.nil?
      puts "unknow squid port listening: #{port}"
      return
    end

    @cache[bind.user_id] ||= {}
    ip_map = @cache[bind.user_id][source_ip] ||= { incoming: 0, outgoing: 0 }
    ip_map[:access_at] = [ ip_map[:access_at], access_at ].compact.min
    ip_map[:incoming] += incoming
    ip_map[:outgoing] += outgoing
  end

  def find_bind(port, access_at)
    SquidBind.where(port: port).where("start_at <= ?", access_at).where("end_at IS NULL OR end_at > ?", access_at).first
  end
end