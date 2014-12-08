# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20140930134224) do

  create_table "geocodes", force: true do |t|
    t.string   "address"
    t.float    "latitude",   limit: 24
    t.float    "longitude",  limit: 24
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "geocodes", ["address"], name: "index_geocodes_on_address", unique: true, using: :btree

  create_table "report_dois", force: true do |t|
    t.string   "doi",        limit: 64, null: false
    t.integer  "report_id"
    t.integer  "sort_order",            null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "report_dois", ["doi"], name: "index_report_dois_on_doi", using: :btree
  add_index "report_dois", ["report_id"], name: "index_report_dois_on_report_id", using: :btree

  create_table "reports", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
