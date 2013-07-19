require "fileutils"

class TcpdumpImporter
  
  attr_accessor :pcap_pathname
  
  def initialize(pcap_pathname)
    self.pcap_pathname = pcap_pathname
  end
  
  def execute
    Rails.logger.info "TCPDUMP START: #{pcap_pathname}"
    calculate_traffics
    record_traffics
    FileUtils.rm_f pcap_pathname
  end
  
  def calculate_traffics
    return if !File.file?(pcap_pathname)
    
    t = pcap_pathname.basename(".*").to_s
    @pcap_file_time = Time.parse(t)
    @pcap_traffics = {}

    rs = Cocaine::CommandLine.new('/usr/sbin/tcpdump', "-n -q -e -r '#{pcap_pathname}'").run
    rs.each_line do |line|
      tcpdump = build_tcpdump(line)
      next if tcpdump.nil?
      
      
      traffic = @pcap_traffics[tcpdump.minute_key] ||= { incoming: 0, outgoing: 0 }
      traffic[:incoming] += tcpdump.incoming_bytes
      traffic[:outgoing] += tcpdump.outgoing_bytes
    end
  end
  
  def find_match_bind(port, access_at)
    SquidBind.where(port: port).where("start_at <= ?", access_at)
                               .where("end_at IS NULL OR end_at > ?", access_at).first
  end
  
  def record_traffics
    @pcap_traffics.each_pair do |minute_key, data|
      access_at, port, remote_ip = *minute_key

      bind = find_match_bind(port, access_at)
      if bind.nil?
        Rails.logger.info "TCPDUMP MISS: #{minute_key} => #{data}"
        next
      end
      
      user = bind.user_id
      traffic = Traffic.where(user_id: user_id, start_at: access_at, remote_ip: remote_ip).new
      traffic.synchronized = false
      traffic.incoming_bytes += data[:incoming]
      traffic.outgoing_bytes += data[:outgoing]
      traffic.save!
    end
  end
  
  # 16:07:30.605593 Out 211.144.112.17.41317 > 211.144.112.30.51338: tcp 501
  # 16:07:30.743496  In 211.144.112.30.51338 > 211.144.112.17.41317: tcp 0
  # 16:07:36.131380  In 00:e0:fc:7c:87:08 211.169.127.86.33237 > 58.196.13.38.22: tcp 0
  def build_tcpdump(line)
    reg = /((?:\d|:|\.)+)\s+(\w+)(?: (?:\w|:)+)* ((?:\d|\.)+)\.(\d+) > ((?:\d|\.)+)\.(\d+): (?:\w+) (\d+)/
    acctime, link_level, src, sport, dst, dport, size = *line.scan(reg).first
    
    acc_at = Time.parse("#{@pcap_file_time.to_date} #{acctime}", "%Y-%m-%d %H:%M:%S.%N")
    acc_at = acc_at + 1.day if acc_at < @pcap_file_time # 16:07:30.605593
    
    link_level = link_level.downcase
    size = size.to_i
    sport = sport.to_i
    dport = dport.to_i
    
    
    if acctime.nil?
      Rails.logger.warn "TCPDUMP UNKNOW: #{line}"
      return nil
    end
    
    return nil if size == 0 # skip
    
    tcpdump = TcpdumpRecord.new
    tcpdump.access_at = acc_at
    tcpdump.link_level = link_level
    tcpdump.src = src
    tcpdump.sport = sport
    tcpdump.dst = dst
    tcpdump.dport = dport
    tcpdump.size = size
    tcpdump.filename = pcap_pathname.basename.to_s
    tcpdump.content = line
    tcpdump
  end
  
  # tcpdump -n -q -e -i any -s 0 -G 30 -w pcaps/%FT%T.pcap "tcp portrange 30000-50000 and not net 127.0.0.1"
  def self.import_all
    source_dir = Rails.root.join("pcaps")
    pcap_pathnames= Pathname.glob(source_dir.join("*.pcap")).sort
    pcap_pathnames.pop # remove current caps
    
    using_dir = source_dir.join("processing")
    pcap_pathnames.each do |pcap_pathname|
      return if !pcap_pathname.exist? # skip because another importer running
      using_pac_pathname = using_dir.join(pcap_pathname.basename)
      pcap_pathname.rename(using_pac_pathname)
      TcpdumpImporter.new(using_pac_pathname).execute
    end
  end
  

  class TcpdumpRecord
    attr_accessor :access_at, :link_level, :src, :sport, :dst, :dport, :size, :filename, :content
    
    def access_begin_minute_at
      self.access_at.change(:sec => 0, :usec => 0)
    end
    
    def local_port
      link_level == "out" ? self.sport : self.dport
    end
    
    def remote_ip
      link_level == "out" ? self.dst : self.src
    end
    
    def minute_key
      [ self.access_begin_minute_at, self.local_port, self.remote_ip ]
    end
    
    def incoming_bytes
      link_level == "out" ? 0 : self.size
    end
    
    def outgoing_bytes
      link_level == "out" ? self.size : 0
    end
    
    def total_transfer_bytes
      self.incoming_bytes + self.outgoing_bytes
    end
  end

end