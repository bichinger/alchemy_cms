# frozen_string_literal: true

module Alchemy
  module Admin
    class EssenceActiveStoragePicturesController < Alchemy::Admin::BaseController
      authorize_resource class: Alchemy::EssenceActiveStoragePicture

      before_action :load_essence_active_storage_picture, only: [:edit, :update]

      helper "alchemy/admin/contents"
      helper "alchemy/admin/essences"
      helper "alchemy/url"

      def edit
        @content = @essence_file.content
      end

      def update
        @essence_file.update(essence_file_params)
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

      private

      def essence_file_params
        params.require(:essence_file).permit(:title, :css_class, :link_text)
      end

      def load_essence_active_storage_picture
        @essence_file = EssenceActiveStoragePicture.find(params[:id])
      end
    end
  end
end
