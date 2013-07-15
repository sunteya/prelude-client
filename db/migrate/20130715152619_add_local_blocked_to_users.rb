class AddLocalBlockedToUsers < ActiveRecord::Migration
  def change
    change_table :users do |t|
      t.boolean :local_blocked, default: false
    end
  end
end
