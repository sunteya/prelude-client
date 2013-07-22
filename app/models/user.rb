# == Schema Information
#
# Table name: users
#
#  id                       :integer          not null, primary key
#  email                    :string(255)
#  upcode                   :string(255)
#  revision                 :integer
#  binding_port             :integer
#  transfer_remaining       :integer          default(0)
#  freeze_transfer          :integer          default(0)
#  local_transfer_remaining :integer          default(0)
#  deleted_at               :datetime
#  created_at               :datetime
#  updated_at               :datetime
#  local_blocked            :boolean          default(FALSE)
#  lock_version             :integer          default(0)
#

class User < ActiveRecord::Base
  has_many :squid_binds

  validates :upcode, uniqueness: true
  
  before_save :build_local_transfer_remaining
  after_save :ensure_queue_squid_update_job

  scope :without_deleted, -> { where("deleted_at IS NULL") }
  scope :available, -> { without_deleted.where("local_transfer_remaining > ?", 0) }

  def build_local_transfer_remaining
    self.local_transfer_remaining = self.transfer_remaining - self.freeze_transfer
    self.local_blocked = self.local_transfer_remaining <= 0
    true
  end

  def ensure_queue_squid_update_job
    if self.local_blocked_changed? || self.deleted_at_changed? || self.binding_port_changed?
      SquidPortsUpdateJob.perform_in(5.seconds)
    end
  end
end
