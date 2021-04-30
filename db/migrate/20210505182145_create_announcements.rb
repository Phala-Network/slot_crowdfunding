class CreateAnnouncements < ActiveRecord::Migration[6.1]
  def change
    create_table :announcements do |t|
      t.references :campaign, null: false, foreign_key: true
      t.string :title, null: false
      t.string :locale, null: false, default: "en"
      t.string :link
      t.string :body
      t.string :published_at

      t.timestamps
    end
  end
end
