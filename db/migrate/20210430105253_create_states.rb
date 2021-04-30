class CreateStates < ActiveRecord::Migration[6.1]
  def change
    create_table :states do |t|
      t.string :chain
      t.string :key, null: false
      t.index %i[chain key], unique: true

      t.boolean :visible, null: false, default: false

      t.decimal :decimal_value
      t.bigint :integer_value
      t.string :string_value
      t.datetime :datetime_value

      t.timestamps
    end
  end
end
