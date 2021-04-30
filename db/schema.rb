# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2021_05_25_182444) do

  create_table "announcements", force: :cascade do |t|
    t.integer "campaign_id", null: false
    t.string "title", null: false
    t.string "locale", default: "en", null: false
    t.string "link"
    t.string "body"
    t.string "published_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["campaign_id"], name: "index_announcements_on_campaign_id"
  end

  create_table "campaigns", force: :cascade do |t|
    t.string "name", null: false
    t.string "chain", null: false
    t.string "parachain_id", null: false
    t.bigint "start_block", null: false
    t.bigint "end_block", null: false
    t.decimal "cap", null: false
    t.decimal "hard_cap", null: false
    t.decimal "raised_amount", default: "0.0", null: false
    t.string "reward_strategy"
    t.date "early_bird_until"
    t.date "estimate_first_releasing_in"
    t.date "estimate_end_releasing_in"
    t.integer "first_releasing_percentage"
    t.integer "estimate_releasing_days_interval"
    t.string "stringify_total_reward_amount"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "coin_market_charts", id: false, force: :cascade do |t|
    t.string "symbol", null: false
    t.datetime "timestamp", null: false
    t.decimal "price", null: false
    t.index ["symbol"], name: "index_coin_market_charts_on_symbol"
    t.index ["timestamp"], name: "index_coin_market_charts_on_timestamp"
  end

  create_table "competitors", force: :cascade do |t|
    t.integer "campaign_id", null: false
    t.string "parachain_ids", null: false
    t.bigint "start_block", default: 0, null: false
    t.bigint "end_block", null: false
    t.decimal "raised_amount", default: "0.0", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["campaign_id"], name: "index_competitors_on_campaign_id"
  end

  create_table "contribution_events", force: :cascade do |t|
    t.string "chain", null: false
    t.bigint "block_num", null: false
    t.string "who", null: false
    t.string "fund_index", null: false
    t.decimal "amount", null: false
    t.datetime "timestamp", null: false
    t.string "on_chain_hash", default: "", null: false
    t.boolean "processed", default: false, null: false
    t.datetime "created_at", null: false
  end

  create_table "contributions", force: :cascade do |t|
    t.integer "campaign_id", null: false
    t.integer "contributor_id", null: false
    t.decimal "amount", null: false
    t.decimal "reward_amount", default: "0.0", null: false
    t.decimal "promotion_reward_amount", default: "0.0", null: false
    t.datetime "timestamp", null: false
    t.string "on_chain_hash", default: "", null: false
    t.integer "event_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["campaign_id"], name: "index_contributions_on_campaign_id"
    t.index ["contributor_id"], name: "index_contributions_on_contributor_id"
    t.index ["event_id"], name: "index_contributions_on_event_id", unique: true
  end

  create_table "contributors", force: :cascade do |t|
    t.integer "campaign_id", null: false
    t.string "address", null: false
    t.integer "referrer_id"
    t.bigint "referrals_count", default: 0, null: false
    t.decimal "amount", default: "0.0", null: false
    t.decimal "reward_amount", default: "0.0", null: false
    t.decimal "promotion_reward_amount", default: "0.0", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["campaign_id", "address"], name: "index_contributors_on_campaign_id_and_address", unique: true
    t.index ["campaign_id"], name: "index_contributors_on_campaign_id"
    t.index ["referrer_id"], name: "index_contributors_on_referrer_id"
  end

  create_table "hourly_contributions", force: :cascade do |t|
    t.integer "campaign_id", null: false
    t.datetime "timestamp", null: false
    t.decimal "amount", default: "0.0", null: false
    t.index ["campaign_id"], name: "index_hourly_contributions_on_campaign_id"
  end

  create_table "milestones", force: :cascade do |t|
    t.integer "campaign_id", null: false
    t.datetime "estimates_at", null: false
    t.string "title"
    t.string "body"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["campaign_id"], name: "index_milestones_on_campaign_id"
  end

  create_table "remark_referrer_events", force: :cascade do |t|
    t.string "chain", null: false
    t.bigint "block_num", null: false
    t.string "who", null: false
    t.string "para_id", null: false
    t.string "referrer", null: false
    t.datetime "timestamp", null: false
    t.string "on_chain_hash", default: "", null: false
    t.boolean "processed", default: false, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "states", force: :cascade do |t|
    t.string "chain"
    t.string "key", null: false
    t.boolean "visible", default: false, null: false
    t.decimal "decimal_value"
    t.bigint "integer_value"
    t.string "string_value"
    t.datetime "datetime_value"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["chain", "key"], name: "index_states_on_chain_and_key", unique: true
  end

  add_foreign_key "announcements", "campaigns"
  add_foreign_key "competitors", "campaigns"
  add_foreign_key "contributions", "campaigns"
  add_foreign_key "contributions", "contribution_events", column: "event_id"
  add_foreign_key "contributions", "contributors"
  add_foreign_key "contributors", "campaigns"
  add_foreign_key "contributors", "contributors", column: "referrer_id"
  add_foreign_key "hourly_contributions", "campaigns"
  add_foreign_key "milestones", "campaigns"
end
