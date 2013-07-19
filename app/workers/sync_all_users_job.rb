class SyncAllUsersJob
  include Sidekiq::Worker
  sidekiq_options queue: :sync
  
  def perform
    users_json = Client.instance.users!['users']
    users_json.each do |json|
      user = User.where(upcode: json['id'].to_s).first_or_initialize
      user.email = json['email']
      user.binding_port = json['binding_port']
      user.transfer_remaining = json['transfer_remaining']
      user.deleted_at = false
      user.save!
    end

    deleted_users = User.without_deleted.where.not(upcode: users_json.map { |m| m['id'].to_s })
    deleted_users.each { |u| u.update(deleted_at: Time.now) }
  end
end
