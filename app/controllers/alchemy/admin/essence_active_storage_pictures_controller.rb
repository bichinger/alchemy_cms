# frozen_string_literal: true

module Alchemy
  module Admin
    class EssenceActiveStoragePicturesController < Alchemy::Admin::BaseController
      authorize_resource class: Alchemy::EssenceActiveStoragePicture

      before_action :load_essence_active_storage_picture, only: [:edit, :crop, :update]
      before_action :load_content, only: [:edit, :update, :assign]

      helper "alchemy/admin/contents"
      helper "alchemy/admin/essences"
      helper "alchemy/url"

      def edit
        # @content = @essence_active_storage_picture.content
      end

      def crop
        if false#@picture = @essence_picture.picture
          # @content = @essence_picture.content
          # @min_size = sizes_from_essence_or_params
          # @ratio = ratio_from_size_or_settings
          # infer_width_or_height_from_ratio
          #
          # @default_box = @essence_picture.default_mask(@min_size)
          # @initial_box = @essence_picture.cropping_mask || @default_box
        else
          @no_image_notice = Alchemy.t(:no_image_for_cropper_found)
        end
      end

      def update
        @essence_active_storage_picture.update(update_params)
      end

      # Assigns file, but does not saves it.
      #
      # When the user saves the element the content gets updated as well.
      #
      def assign
        @content = Content.find_by(id: params[:content_id])
        @active_storage_file = ActiveStorageFile.find_by(id: params[:active_storage_file_id])
        @content.essence.active_storage_file = @active_storage_file
        # @content.essence.active_storage_file.file.attach( @active_storage_file )

        # We need to update timestamp here because we don't save yet,
        # but the cache needs to be get invalid.
        @content.touch
      end

      def destroy
        # @content = Content.find_by(id: params[:id])
        # @element = @content.element
        # @content_id = @content.id
        # @content.destroy
        # @essence_active_storage_pictures = @element.contents.essence_active_storage_pictures
      end

      private

      def update_params
        params.require(:essence_active_storage_picture).permit(:alt_tag, :caption, :css_class, :render_size, :title, :crop_from, :crop_size)
      end

      def load_essence_active_storage_picture
        @essence_active_storage_picture = EssenceActiveStoragePicture.find(params[:id])
      end

      def load_content
        @content = Content.find(params[:content_id])
      end

    end
  end
end
