class AddTrackingColumnsToCampaigns < ActiveRecord::Migration[6.1]
  def change
    change_table :campaigns do |t|
      t.boolean :tracking_raised, null: false, default: true
      t.boolean :tracking_contribution, null: false, default: true

      t.decimal :raised_amount, null: false, default: 0
      t.bigint :current_block_num, null: false, default: 0
    end
  end
end
