class AddLockVersionToUsers < ActiveRecord::Migration
  def change
    change_table :users do |t|
      t.integer :lock_version, default: 0
    end
  end
end
