class CreateContributions < ActiveRecord::Migration[6.1]
  def change
    create_table :contributions do |t|
      t.references :campaign, null: false, foreign_key: true
      t.references :contributor, null: false, foreign_key: true
      t.decimal :amount, null: false
      t.decimal :reward_amount, null: false, default: 0
      t.decimal :reward_amount_for_referrer, null: false, default: 0

      t.timestamps
    end
  end
end
