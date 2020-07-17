class CreateEssenceActiveStoragePicture < ActiveRecord::Migration[6.0]
  def change
    create_table :alchemy_essence_active_storage_pictures do |t|
      t.timestamps

      t.references :active_storage_file, foreign_key: {to_table: :alchemy_active_storage_file}, index: { name: :index_alchemy_essence_active_storage_pictures_on_file_id }

      t.string :caption, default: nil
      t.string :title, default: nil
      t.string :alt_tag, default: nil
      t.string :link, default: nil
      t.string :link_class_name, default: nil
      t.string :link_title, default: nil
      t.string :css_class, default: nil
      t.string :link_target, default: nil
      t.string :crop_from, default: nil
      t.string :crop_size, default: nil
      t.string :render_size, default: nil
    end
  end
end
