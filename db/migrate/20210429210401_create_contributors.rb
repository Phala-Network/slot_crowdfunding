class CreateContributors < ActiveRecord::Migration[6.1]
  def change
    create_table :contributors do |t|
      t.references :campaign, null: false, foreign_key: { to_table: :campaigns }, references: :campaigns
      t.string :address, null: false
      t.index %i[campaign_id address], unique: true

      t.references :referrer, foreign_key: { to_table: :contributors }, references: :contributors
      t.bigint :referrals_count, null: false, default: 0

      t.decimal :amount, null: false, default: 0
      t.decimal :reward_amount, null: false, default: 0
      t.decimal :promotion_reward_amount, null: false, default: 0

      t.timestamps
    end
  end
end
