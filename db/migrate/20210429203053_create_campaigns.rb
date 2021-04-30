class CreateCampaigns < ActiveRecord::Migration[6.1]
  def change
    create_table :campaigns do |t|
      t.string :name, null: false
      t.string :chain, null: false
      t.string :parachain_id, null: false
      t.bigint :start_block, null: false
      t.bigint :end_block, null: false
      t.decimal :cap, null: false
      t.decimal :hard_cap, null: false

      t.decimal :raised_amount, null: false, default: 0

      t.string :reward_strategy
      t.date :early_bird_until
      t.date :estimate_first_releasing_in
      t.date :estimate_end_releasing_in
      t.integer :first_releasing_percentage
      t.integer :estimate_releasing_days_interval
      t.string :stringify_total_reward_amount

      t.timestamps
    end
  end
end
