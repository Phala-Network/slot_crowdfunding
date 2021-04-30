class CreateMilestones < ActiveRecord::Migration[6.1]
  def change
    create_table :milestones do |t|
      t.references :campaign, null: false, foreign_key: true
      t.datetime :estimates_at, null: false
      t.string :title
      t.string :body

      t.timestamps
    end
  end
end
