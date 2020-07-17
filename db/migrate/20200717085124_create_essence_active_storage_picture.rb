class CreateEssenceActiveStoragePicture < ActiveRecord::Migration[5.2]
  def change
    create_table :alchemy_essence_active_storage_pictures do |t|
      t.timestamps

      t.references :active_storage_file, foreign_key: {to_table: :alchemy_active_storage_file}, index: {name: :index_alchemy_essence_active_storage_pictures_on_file_id}
      t.string :caption
      t.string :title
      t.string :alt_tag
      t.string :link
      t.string :link_class_name
      t.string :link_title
      t.string :css_class
      t.string :link_target
      t.string :crop_from
      t.string :crop_size
      t.string :render_size
    end
  end
end
