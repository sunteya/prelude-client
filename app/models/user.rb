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
#

class User < ActiveRecord::Base
  validates :upcode, uniqueness: true
  before_save :build_local_transfer_remaining

  scope :without_deleted, -> { where("deleted_at NOT NULL") }
  scope :available, -> { without_deleted.where("local_transfer_remaining > ?", 0) }

  def build_local_transfer_remaining
    self.local_transfer_remaining = self.transfer_remaining - self.freeze_transfer
  end
end
