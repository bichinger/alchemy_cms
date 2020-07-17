# frozen_string_literal: true
class CreateActiveStorageFiles < ActiveRecord::Migration[5.2]
  def change
    create_table :alchemy_active_storage_files do |t|
      t.timestamps

      t.string :name
    end
  end
end
