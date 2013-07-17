class SyncTrafficJob
  include Sidekiq::Worker
  sidekiq_options queue: :sync
  
  def perform(traffic_id)
    traffic = Traffic.where(id: traffic_id, synchronized: false).joins(:user).readonly(false).first
    return if traffic.nil?

    result = Client.instance.update_traffic(traffic)
    case result['error_code']
    when nil
      traffic_created(traffic, result['user'])
    when 'user_not_found'
      user_not_found(traffic)
    else
      raise "unknow error_code: #{result['error_code']}"
    end
  end

  def traffic_created(traffic, json)
    traffic.synchronized = true
    traffic.save!
    
    user = traffic.user
    user.email = json['email']
    user.binding_port = json['binding_port']
    user.transfer_remaining = json['transfer_remaining']
    user.save!
  rescue ActiveRecord::StaleObjectError
    traffic.reload
    retry
  end

  def user_not_found(traffic)
    user = traffic.user
    user.deleted_at = Time.now
    user.save!
  rescue ActiveRecord::StaleObjectError
    user.reload
    retry
  end
end
