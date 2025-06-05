class AddUniqueIndexToTags < ActiveRecord::Migration[8.0]
  def change
    add_index :tags, [:name, :tag_type], unique: true
  end
end
