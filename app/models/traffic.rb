# == Schema Information
#
# Table name: traffics
#
#  id                   :integer          not null, primary key
#  user_id              :integer
#  start_at             :datetime
#  remote_ip            :string(255)
#  incoming_bytes       :integer          default(0)
#  outgoing_bytes       :integer          default(0)
#  total_transfer_bytes :integer          default(0)
#  synchronized         :boolean          default(FALSE)
#  created_at           :datetime
#  updated_at           :datetime
#

class Traffic < ActiveRecord::Base
  belongs_to :user

  validates :user, :presence => true

  before_save :build_total_transfer_bytes
  after_save :cascade_user_freeze_transfer, if: :synchronized_changed?
  after_save :perpare_sync_traffic_job

  def perpare_sync_traffic_job
    SyncTrafficJob.perform_async(self.id) if self.synchronized == false
  end

  def build_total_transfer_bytes
    self.total_transfer_bytes = self.incoming_bytes + self.outgoing_bytes
  end

  def cascade_user_freeze_transfer
    self.user.freeze_transfer -= self.total_transfer_bytes_was if self.synchronized_was == false
    self.user.freeze_transfer += self.total_transfer_bytes if self.synchronized == false
    self.user.save!
  rescue ActiveRecord::StaleObjectError
    self.user.reload
    retry
  end
end
