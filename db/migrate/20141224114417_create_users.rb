class CreateUsers < ActiveRecord::Migration
  def change
    create_table "users", force: true do |t|
      t.string   "email",                  default: ""
      t.string   "encrypted_password",     default: "",     null: false
      t.string   "reset_password_token"
      t.datetime "reset_password_sent_at"
      t.datetime "remember_created_at"
      t.integer  "sign_in_count",          default: 0
      t.datetime "current_sign_in_at"
      t.datetime "last_sign_in_at"
      t.string   "current_sign_in_ip"
      t.string   "last_sign_in_ip"
      t.string   "password_salt"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "provider"
      t.string   "uid"
      t.string   "name"
      t.string   "authentication_token"
    end

    add_index "users", ["authentication_token"], name: "index_users_authentication_token", unique: true, using: :btree
    add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
    add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

    create_table "reports_users", id: false, force: true do |t|
      t.integer "report_id"
      t.integer "user_id"
    end

    add_index "reports_users", ["report_id", "user_id"], name: "index_reports_users_on_report_id_and_user_id", using: :btree
    add_index "reports_users", ["user_id"], name: "index_reports_users_on_user_id", using: :btree
  end
end
