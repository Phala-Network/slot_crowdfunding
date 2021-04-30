class CreateCoinMarketCharts < ActiveRecord::Migration[6.1]
  def change
    create_table :coin_market_charts, id: false do |t|
      t.string :symbol, null: false, index: true
      t.datetime :timestamp, null: false, index: true
      t.decimal :price, null: false
    end
  end
end
