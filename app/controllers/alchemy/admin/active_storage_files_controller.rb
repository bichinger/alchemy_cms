# frozen_string_literal: true

module Alchemy
  module Admin
    class ActiveStorageFilesController < Alchemy::Admin::ResourcesController
      include UploaderResponses
      include ArchiveOverlay

      helper "alchemy/admin/tags"

      before_action :load_resource,
                    only: [:show, :edit, :update, :destroy, :info]

      authorize_resource class: Alchemy::ActiveStorageFile

      def index
        @query = ActiveStorageFile.ransack(search_filter_params[:q])
        @active_storage_files = ActiveStorageFile.search_by(
            search_filter_params,
            @query,
            items_per_page,
        )

        if in_overlay?
          archive_overlay
        end
      end

      def show
        # @previous = @picture.previous(params)
        # @next = @picture.next(params)
        # @assignments = @picture.essence_pictures.joins(content: {element: :page})
        # render action: "show"

        render :show
      end

      def create
        @active_storage_file = ActiveStorageFile.create!(create_params)

        if @active_storage_file && @active_storage_file.file.attached?
          render successful_uploader_response(file: @active_storage_file)
        else
          render failed_uploader_response(file: @active_storage_file)
        end
      end

      def update
        @active_storage_file.update(update_params)
        if update_params[:file].present?
          handle_uploader_response(status: :accepted)
        else
          render_errors_or_redirect(
              @active_storage_file,
              admin_active_storage_files_path(search_filter_params),
              Alchemy.t("File successfully updated"),
          )
        end
      end

      def destroy
        @active_storage_file.file.purge if @active_storage_file.file.attached?

        name = @active_storage_file.name
        @active_storage_file.destroy
        flash[:notice] = Alchemy.t("File deleted successfully", name: name)
      rescue StandardError => e
        flash[:error] = e.message
      ensure
        redirect_to_index
      end

      def items_per_page
        if in_overlay?
          12
        else
          cookies[:alchemy_items_per_page] = params[:per_page] || cookies[:alchemy_items_per_page] || Alchemy::Config.get(:items_per_page)
        end
      end


      private


      def redirect_to_index
        do_redirect_to admin_active_storage_files_path(search_filter_params)
      end

      def search_filter_params
        @_search_filter_params ||= params.except(*COMMON_SEARCH_FILTER_EXCLUDES + [:active_storage_file])
           .permit(
               *common_search_filter_includes + [
                   :file_type,
                   :content_id,
               ],
           )
      end

      def handle_uploader_response(status:)
        if @active_storage_file.valid?
          render successful_uploader_response(file: @active_storage_file, status: status)
        else
          render failed_uploader_response(file: @active_storage_file)
        end
      end

      def create_params
        params.require(:active_storage_file).permit(:file, :name, :tag_list)
      end

      def update_params
        params.require(:active_storage_file).permit(:file, :name, :tag_list)
      end
    end
  end
end
