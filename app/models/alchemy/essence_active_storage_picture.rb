module Alchemy
  class EssenceActiveStoragePicture < BaseRecord
    acts_as_essence ingredient_column: :active_storage_file, belongs_to: {
        class_name: "Alchemy::ActiveStorageFile",
        foreign_key: :active_storage_file_id,
        inverse_of: :essence_active_storage_pictures,
        optional: true,
    }

    def allow_image_cropping?
      # content && content.settings[:crop] && picture &&
      #     picture.can_be_cropped_to(
      #         content.settings[:size],
      #         content.settings[:upsample],
      #     )

      false
    end

    # Returns an url for the thumbnail representation of the assigned picture
    #
    # It takes cropping values into account, so it always represents the current
    # image displayed in the frontend.
    #
    # @return [String]
    def thumbnail_url
      return if active_storage_file_id.nil?

      # crop = crop_values_present? || content.settings[:crop]
      # size = render_size || content.settings[:size]
      #
      # options = {
      #     size: thumbnail_size(size, crop),
      #     crop: !!crop,
      #     crop_from: crop_from.presence,
      #     crop_size: crop_size.presence,
      #     flatten: true,
      #     format: picture.image_file_format,
      # }
      #
      # picture.url(options)

      # TODO: Change essences_helper to be able to generate blob paths...
      rails_blob_path(active_storage_file.file, disposition: "attachment")
    end

    # def routes
    #   @routes ||= Engine.routes.url_helpers
    # end

  end
end
