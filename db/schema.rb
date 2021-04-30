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

ActiveRecord::Schema.define(version: 2021_04_30_161521) do

  create_table "campaigns", force: :cascade do |t|
    t.string "name", null: false
    t.string "chain", null: false
    t.string "parachain_id", null: false
    t.bigint "start_block", null: false
    t.bigint "end_block", null: false
    t.decimal "cap", null: false
    t.string "status", default: "created", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "tracking_raised", default: true, null: false
    t.boolean "tracking_contribution", default: true, null: false
    t.decimal "raised_amount", default: "0.0", null: false
    t.bigint "current_block_num", default: 0, null: false
  end

  create_table "contribution_events", force: :cascade do |t|
    t.string "chain", null: false
    t.bigint "block_num", null: false
    t.string "who", null: false
    t.string "fund_index", null: false
    t.decimal "amount", null: false
    t.boolean "processed", default: false, null: false
    t.datetime "created_at", null: false
  end

  create_table "contributions", force: :cascade do |t|
    t.integer "campaign_id", null: false
    t.integer "contributor_id", null: false
    t.decimal "amount", null: false
    t.decimal "reward_amount", default: "0.0", null: false
    t.decimal "reward_amount_for_referrer", default: "0.0", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["campaign_id"], name: "index_contributions_on_campaign_id"
    t.index ["contributor_id"], name: "index_contributions_on_contributor_id"
  end

  create_table "contributors", force: :cascade do |t|
    t.integer "campaign_id", null: false
    t.string "address", null: false
    t.integer "referrer_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.decimal "amount", default: "0.0", null: false
    t.decimal "reward_amount", default: "0.0", null: false
    t.bigint "referrals_count", default: 0, null: false
    t.decimal "referral_reward_amount", default: "0.0", null: false
    t.index ["campaign_id", "address"], name: "index_contributors_on_campaign_id_and_address", unique: true
    t.index ["campaign_id"], name: "index_contributors_on_campaign_id"
    t.index ["referrer_id"], name: "index_contributors_on_referrer_id"
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

  add_foreign_key "contributions", "campaigns"
  add_foreign_key "contributions", "contributors"
  add_foreign_key "contributors", "campaigns"
  add_foreign_key "contributors", "contributors", column: "referrer_id"
end
