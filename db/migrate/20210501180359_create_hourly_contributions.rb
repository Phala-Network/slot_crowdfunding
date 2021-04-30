class CreateHourlyContributions < ActiveRecord::Migration[6.1]
  def change
    create_table :hourly_contributions do |t|
      t.references :campaign, null: false, foreign_key: true
      t.datetime :timestamp, null: false
      t.decimal :amount, null: false, default: 0
    end
  end
end
