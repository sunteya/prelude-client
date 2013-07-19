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
    @input_rules = Cocaine::CommandLine.new(iptables_bin, "-L INPUT -n").run
  end

  def exist?(ip)
    @input_rules =~ /ACCEPT.*#{ip}\s/
  end

  def drop(ip)
    if exist?(ip)
      Cocaine::CommandLine.new(iptables_bin, "-D INPUT -s #{ip} -j ACCEPT").run
    end
  end

  def accept(ip)
    if !exist?(ip)
      Cocaine::CommandLine.new(iptables_bin, "-I INPUT -s #{ip} -j ACCEPT").run
    end
  end
end

