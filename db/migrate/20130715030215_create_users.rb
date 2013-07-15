class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :email
      t.string :upcode
      t.integer :revision
      t.integer :binding_port
      t.integer :transfer_remaining, limit: 8, default: 0
      t.integer :freeze_transfer, limit: 8, default: 0
      t.integer :local_transfer_remaining, limit: 8, default: 0
      t.datetime :deleted_at

      t.timestamps
    end

    add_index :users, :upcode
  end
end
