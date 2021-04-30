class CreateContributions < ActiveRecord::Migration[6.1]
  def change
    create_table :contributions do |t|
      t.references :campaign, null: false, foreign_key: true
      t.references :contributor, null: false, foreign_key: true
      t.decimal :amount, null: false
      t.decimal :reward_amount, null: false, default: 0
      t.decimal :promotion_reward_amount, null: false, default: 0
      t.datetime :timestamp, null: false
      t.string :on_chain_hash, null: false, default: ""

      t.references :event, null: false, foreign_key: { to_table: :contribution_events }, index: { unique: true }

      t.timestamps
    end
  end
end
