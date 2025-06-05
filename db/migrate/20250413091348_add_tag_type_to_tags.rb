class AddTagTypeToTags < ActiveRecord::Migration[8.0]
  def change
    add_column :tags, :tag_type, :string
  end
end
