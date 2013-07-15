class SyncAllUsersJob
  include Sidekiq::Worker
  
  def perform
    users_json = Client.instance.users
    users_json.each do |json|
      user = User.where(upcode: json['id']).first_or_initialize
      user.email = json['email']
      user.revision = json['lock_version']
      user.binding_port = json['binding_port']
      user.transfer_remaining = json['transfer_remaining']
      user.save!
    end

    deleted_users = User.without_deleted.where.not(upcode: users_json.map { |m| m['id'] })
    deleted_users.each { |u| u.update(deleted_at: Time.now) }
  end
end
