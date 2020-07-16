# frozen_string_literal: true
module Alchemy
  class ActiveStorageFile < BaseRecord
    include Alchemy::Filetypes
    include Alchemy::Taggable

    has_one_attached :file

    with_options(presence: true) do
      validates :file
      validates :name
    end

    scope :recent, -> { where("#{table_name}.created_at > ?", Time.current - 24.hours).order(:created_at) }
    scope :without_tag, -> { left_outer_joins(:taggings).where(gutentag_taggings: { id: nil }) }

    def self.searchable_alchemy_resource_attributes
      %w(name)
    end

    def self.last_upload
      last_file = ActiveStorageFile.last
      return ActiveStorageFile.all unless last_file

      ActiveStorageFile.where(upload_hash: last_file.upload_hash)
    end

    def self.search_by(params, query, per_page = nil)
      files = query.result

      if params[:tagged_with].present?
        files = files.tagged_with(params[:tagged_with])
      end

      if params[:filter].present?
        files = files.filtered_by(params[:filter])
      end

      if per_page
        files = files.page(params[:page] || 1).per(per_page)
      end

      files.order(:name)
    end

    def self.filtered_by(filter = "")
      case filter
      when "recent" then recent
      when "last_upload" then last_upload
      when "without_tag" then without_tag
      else
        all
      end
    end

    # def self.file_types_for_select
    #   file_types = Alchemy::ActiveStorageFile.all.file.blob.pluck(:content_type).uniq.map do |type|
    #     [Alchemy.t(type, scope: "mime_types"), type]
    #   end
    #   file_types.sort_by(&:first)
    # end

    def self.alchemy_resource_filters
      %w(recent last_upload without_tag)
    end


    # Returns a css class name for kind of file
    #
    def icon_css_class
      case self.file.content_type
      when "application/pdf"
        "file-pdf"
      when "application/msword"
        "file-word"
      when *TEXT_FILE_TYPES
        "file-alt"
      when *EXCEL_FILE_TYPES
        "file-excel"
      when *VCARD_FILE_TYPES
        "address-card"
      when *ARCHIVE_FILE_TYPES
        "file-archive"
      when *AUDIO_FILE_TYPES
        "file-audio"
      when *IMAGE_FILE_TYPES
        "file-image"
      when *VIDEO_FILE_TYPES
        "file-video"
      else
        "file"
      end
    end

  end
end
