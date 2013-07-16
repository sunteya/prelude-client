# == Schema Information
#
# Table name: squid_binds
#
#  id         :integer          not null, primary key
#  start_at   :datetime
#  end_at     :datetime
#  user_id    :integer
#  port       :integer
#  created_at :datetime
#  updated_at :datetime
#

class SquidBind < ActiveRecord::Base
  belongs_to :user
  scope :using, -> { where("end_at IS NULL") }

  def close!
    self.end_at ||= Time.now
    self.save!
  end
end
