class CreateSquidLogAnalysisStates < ActiveRecord::Migration
  def change
    create_table :squid_log_analysis_states do |t|
      t.string :filename, index: true
      t.string :log_file_path, limit: 1000
      t.integer :position, default: 0

      t.timestamps
    end
  end
end
