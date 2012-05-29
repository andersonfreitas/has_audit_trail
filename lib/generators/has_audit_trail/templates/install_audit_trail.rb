class <%= migration_class_name %> < ActiveRecord::Migration
  def self.up

    create_table "audit_trails", :force => true do |t|
      t.integer  "user_id"

      t.string   "remote_address"
      t.string   "user_agent"

      t.string   "action"
      t.string   "object"
      t.string   "object_id"
      t.string   "property"
      t.string   "old_value"
      t.string   "new_value"
      t.datetime "created_at",     :null => false
    end

    add_index :audit_trails, :user_id
    add_index :audit_trails, :created_at
  end

  def self.down
    drop_table :audit_trails
  end
end

