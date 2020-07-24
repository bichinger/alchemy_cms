module Alchemy
  class EssenceActiveStoragePicture < BaseRecord
    acts_as_essence ingredient_column: :active_storage_file, belongs_to: {
        class_name: "Alchemy::ActiveStorageFile",
        foreign_key: :active_storage_file_id,
        inverse_of: :essence_active_storage_pictures,
        optional: true,
    }

    # Show image cropping link for content
    def allow_image_cropping?
      content && content.settings[:crop] && active_storage_file &&
          can_be_cropped_to(
              content.settings[:size],
              content.settings[:upsample],
          ) && active_storage_file.file.attached?
    end

    # def can_be_cropped_to(string, upsample = false)
    #   return true if upsample
    #
    #   is_bigger_than sizes_from_string(string)
    # end

    def picture_url(options = {})
      return if !active_storage_file || !active_storage_file.file.attached?

      # picture.url picture_url_options.merge(options)

      # TODO: Use ActiveStorage::Variants on this point!
      # merged_options = picture_url_options.merge(options)
      # active_storage_file.file.variant(
      #
      # )

      # DEV ONLY: Just return URL to picture . . .
      Rails.application.routes.url_helpers.url_for(active_storage_file.file)
    end

    # Picture rendering options
    #
    # Returns the +default_render_format+ of the associated +Alchemy::Picture+
    # together with the +crop_from+ and +crop_size+ values
    #
    # @return [HashWithIndifferentAccess]
    def picture_url_options
      return {} if !active_storage_file || !active_storage_file.file.attached?

      {
          format: active_storage_file.file.blob.content_type,
          crop_from: crop_from.presence,
          crop_size: crop_size.presence,
          size: content.settings[:size],
      }.with_indifferent_access
    end

    # Returns an ActiveStorage::Variant for the thumbnail representation of the assigned picture
    #
    # It takes cropping values into account, so it always represents the current
    # image displayed in the frontend.
    #
    # @return [ActiveStorage::Variant]
    def thumbnail_url
      return if active_storage_file_id.nil?

      crop = crop_values_present? || content.settings[:crop]
      size = render_size || content.settings[:size]

      # throw "content: #{content.inspect}   | settings: #{content.settings.inspect}"

      # options = {
      #     size: thumbnail_size(size, crop),
      #     crop: !!crop,
      #     crop_from: crop_from.presence,
      #     crop_size: crop_size.presence,
      #     flatten: true,
      #     format: picture.image_file_format,
      # }

      # picture.url(options)

      # rails_blob_path(active_storage_file.file, disposition: "attachment")

      # TODO: Use ActiveStorage::Variants on this point!
      active_storage_file.file.variant(
          resize_to_limit: [100, 100],
      )
    end

    def crop_values_present?
      crop_from.present? && crop_size.present?
    end

    # def routes
    #   @routes ||= Engine.routes.url_helpers
    # end

  end
end
