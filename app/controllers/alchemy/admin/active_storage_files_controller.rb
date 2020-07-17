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
        # @size = params[:size].present? ? params[:size] : "medium"
        # @query = Picture.ransack(search_filter_params[:q])
        # @pictures = Picture.search_by(
        #   search_filter_params,
        #   @query,
        #   items_per_page,
        # )
        #
        # if in_overlay?
        #   archive_overlay
        # end

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
      rescue StandardError => e
        flash[:error] = e.message
      ensure
        redirect_to_index
      end

      # def edit_multiple
        # @pictures = Picture.where(id: params[:picture_ids])
        # @tags = @pictures.collect(&:tag_list).flatten.uniq.join(", ")
      # end

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

      # def update_multiple
        # @pictures = Picture.find(params[:picture_ids])
        # @pictures.each do |picture|
        #   picture.update_name_and_tag_list!(params)
        # end
        # flash[:notice] = Alchemy.t("Pictures updated successfully")
        # redirect_to_index
      # end

      # def delete_multiple
        #   if request.delete? && params[:picture_ids].present?
        #     pictures = Picture.find(params[:picture_ids])
        #     names = []
        #     not_deletable = []
        #     pictures.each do |picture|
        #       if picture.deletable?
        #         names << picture.name
        #         picture.destroy
        #       else
        #         not_deletable << picture.name
        #       end
        #     end
        #     if not_deletable.any?
        #       flash[:warn] = Alchemy.t(
        #         "These pictures could not be deleted, because they were in use",
        #         names: not_deletable.to_sentence,
        #       )
        #     else
        #       flash[:notice] = Alchemy.t("Pictures deleted successfully", names: names.to_sentence)
        #     end
        #   else
        #     flash[:warn] = Alchemy.t("Could not delete Pictures")
        #   end
        # rescue StandardError => e
        #   flash[:error] = e.message
        # ensure
        #   redirect_to_index
      # end

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
        cookies[:alchemy_items_per_page] = params[:per_page] || cookies[:alchemy_items_per_page] || Alchemy::Config.get(:items_per_page)
      end

      def items_per_page_options
        per_page = Alchemy::Config.get(:items_per_page)
        [per_page, per_page * 2, per_page * 4]
      end

      private

      def redirect_to_index
        do_redirect_to admin_active_storage_files_path(search_filter_params)
      end

      def search_filter_params
        @_search_filter_params ||= params.except(*COMMON_SEARCH_FILTER_EXCLUDES + [:active_storage_file]).permit(
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
