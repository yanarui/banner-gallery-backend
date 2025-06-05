class CreateBannerTags < ActiveRecord::Migration[8.0]
  def change
    create_table :banner_tags do |t|
      t.references :banner, null: false, foreign_key: true
      t.references :tag, null: false, foreign_key: true

      t.timestamps
    end
  end
end
