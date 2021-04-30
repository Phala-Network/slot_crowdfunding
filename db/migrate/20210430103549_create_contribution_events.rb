class CreateContributionEvents < ActiveRecord::Migration[6.1]
  def change
    create_table :contribution_events do |t|
      t.string :chain, null: false
      t.bigint :block_num, null: false
      t.string :who, null: false
      t.string :fund_index, null: false

      t.decimal :amount, null: false

      t.boolean :processed, null: false, default: false

      t.datetime :created_at, null: false
    end
  end
end
