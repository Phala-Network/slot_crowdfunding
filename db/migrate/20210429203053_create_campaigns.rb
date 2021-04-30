class CreateCampaigns < ActiveRecord::Migration[6.1]
  def change
    create_table :campaigns do |t|
      t.string :name, null: false
      t.string :chain, null: false
      t.string :parachain_id, null: false
      t.bigint :start_block, null: false
      t.bigint :end_block, null: false
      t.decimal :cap, null: false
      t.string :status, null: false, default: "created"

      t.timestamps
    end
  end
end
