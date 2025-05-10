class CreatePostTags < ActiveRecord::Migration[8.1]
  def change
    create_table :post_tags do |t|
      t.references :post, null: false, foreign_key: true
      t.string :tag

      t.timestamps
    end
  end
end
