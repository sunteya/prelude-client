class UpdateIptableJob
  include Sidekiq::Worker
  sidekiq_options queue: :iptables
  
  def perform
    prepare

    Dir[Rails.root.join("allow/*")].each do |path|
      ip = File.basename(path)
      next if ip =~ /^\./
      
      if File.mtime(path) < Time.now - 12.hours
        drop ip
      else
        accept ip
      end
    end
  end

  def iptables_bin
    "/sbin/iptables"
  end

  def prepare
    @iptables_bin
    @input_rules = `#{iptables_bin} -L INPUT -n`
  end

  def exist?(ip)
    @input_rules =~ /ACCEPT.*#{ip}\s/
  end

  def drop(ip)
    if exist?(ip)
      command = "#{iptables_bin} -D INPUT -s #{ip} -j ACCEPT"
      `#{command}`
    end
  end

  def accept(ip)
    if !exist?(ip)
      command = "#{iptables_bin} -I INPUT -s #{ip} -j ACCEPT"
      `#{command}`
    end
  end
end

