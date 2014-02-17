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

ActiveRecord::Schema.define(version: 20140217173630) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "batches", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "kitter_sessions", force: true do |t|
    t.integer  "sub_id"
    t.text     "product_ids"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "line_items", force: true do |t|
    t.integer  "order_id"
    t.integer  "product_id"
    t.float    "rate"
    t.integer  "q"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "orders", force: true do |t|
    t.string   "order_number"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "sub_id"
    t.string   "plan"
    t.string   "name"
    t.string   "email"
    t.string   "address"
    t.string   "address2"
    t.string   "city"
    t.string   "state"
    t.string   "zip"
    t.string   "country"
    t.string   "billing_name"
    t.string   "billing_address"
    t.string   "billing_address2"
    t.string   "billing_city"
    t.string   "billing_state"
    t.string   "billing_zip"
    t.string   "billing_country"
    t.integer  "batch_id"
    t.integer  "trans_id"
    t.integer  "ssid"
    t.float    "amt",              default: 0.0
    t.string   "type"
  end

  add_index "orders", ["batch_id"], name: "index_orders_on_batch_id", using: :btree
  add_index "orders", ["sub_id"], name: "index_orders_on_sub_id", using: :btree

  create_table "orders_products", force: true do |t|
    t.integer "sub_order_id"
    t.integer "product_id"
  end

  create_table "outstanding_renewals", force: true do |t|
    t.integer  "trans_id"
    t.integer  "cid"
    t.string   "name"
    t.string   "plan"
    t.float    "amount"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "outstanding_signups", force: true do |t|
    t.integer  "trans_id"
    t.integer  "cid"
    t.string   "name"
    t.string   "plan"
    t.float    "amount"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "prefs", force: true do |t|
    t.string   "pref"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "prefs_products", force: true do |t|
    t.integer "pref_id"
    t.integer "product_id"
  end

  create_table "prefs_subs", force: true do |t|
    t.integer "pref_id"
    t.integer "sub_id"
  end

  create_table "products", force: true do |t|
    t.string   "sku"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "q"
    t.boolean  "active",     default: true
  end

  create_table "subs", force: true do |t|
    t.integer  "cid"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "upfront",    default: false
  end

end
