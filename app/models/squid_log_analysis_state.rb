class SquidLogAnalysisState < ActiveRecord::Base
  validates :filename, presence: true
end
