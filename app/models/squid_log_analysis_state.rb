# == Schema Information
#
# Table name: squid_log_analysis_states
#
#  id            :integer          not null, primary key
#  filename      :string(255)
#  log_file_path :string(1000)
#  position      :integer          default(0)
#  created_at    :datetime
#  updated_at    :datetime
#

class SquidLogAnalysisState < ActiveRecord::Base
  validates :filename, presence: true
  after_destroy :remove_log_file

  def remove_log_file
    FileUtils.rm(log_file_path) if log_file_path && File.exists?(log_file_path)
  end
end
