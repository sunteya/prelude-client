class CreateTraffics < ActiveRecord::Migration
  def change
    create_table :traffics do |t|
      t.references :user, index: true
      t.datetime   :start_at
      t.string     :remote_ip
      t.integer    :incoming_bytes, limit: 8, default: 0
      t.integer    :outgoing_bytes, limit: 8, default: 0
      t.integer    :total_transfer_bytes, limit: 8, default: 0
      t.boolean    :synchronized, default: false

      t.timestamps
    end
  end
end
