class CreateCompetitors < ActiveRecord::Migration[6.1]
  def change
    create_table :competitors do |t|
      t.references :campaign, null: false, foreign_key: true
      t.string :parachain_ids, null: false
      t.bigint :start_block, null: false, default: 0
      t.bigint :end_block, null: false
      t.decimal :raised_amount, null: false, default: 0

      t.timestamps
    end
  end
end
