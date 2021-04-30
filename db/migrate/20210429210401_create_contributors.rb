class CreateContributors < ActiveRecord::Migration[6.1]
  def change
    create_table :contributors do |t|
      t.references :campaign, null: false, foreign_key: { to_table: :campaigns }, references: :campaigns
      t.string :address, null: false
      t.index %i[campaign_id address], unique: true

      t.references :referrer, foreign_key: { to_table: :contributors }, references: :contributors

      t.timestamps
    end
  end
end
