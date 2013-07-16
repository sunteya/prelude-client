class CreateSquidBinds < ActiveRecord::Migration
  def change
    create_table :squid_binds do |t|
      t.datetime :start_at
      t.datetime :end_at
      t.references :user, index: true
      t.integer :port

      t.timestamps
    end

    User.all.each do |user|
      bind = user.squid_binds.new
      bind.start_at = user.created_at
      bind.port = user.binding_port
      bind.save
    end
  end
end
