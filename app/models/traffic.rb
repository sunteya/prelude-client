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
end
