class CreateRemarkReferrerEvents < ActiveRecord::Migration[6.1]
  def change
    create_table :remark_referrer_events do |t|
      t.string :chain, null: false
      t.bigint :block_num, null: false
      t.string :who, null: false

      t.string :para_id, null: false
      t.string :referrer, null: false
      t.datetime :timestamp, null: false
      t.string :on_chain_hash, null: false, default: ""

      t.boolean :processed, null: false, default: false

      t.timestamps
    end
  end
end
