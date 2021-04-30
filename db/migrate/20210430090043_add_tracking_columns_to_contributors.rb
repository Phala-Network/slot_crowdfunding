class AddTrackingColumnsToContributors < ActiveRecord::Migration[6.1]
  def change
    change_table :contributors do |t|
      t.decimal :amount, null: false, default: 0
      t.decimal :reward_amount, null: false, default: 0

      t.bigint :referrals_count, null: false, default: 0
      t.decimal :referral_reward_amount, null: false, default: 0
    end
  end
end
