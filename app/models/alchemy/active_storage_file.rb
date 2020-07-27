# frozen_string_literal: true
module Alchemy
  class ActiveStorageFile < BaseRecord
    include Alchemy::Filetypes
    include Alchemy::Taggable

    has_one_attached :file

    has_many :essence_active_storage_pictures,
             class_name: "Alchemy::EssenceActiveStoragePicture",
             foreign_key: :active_storage_file_id,
             inverse_of: :ingredient_association

    has_many :contents, through: :essence_active_storage_pictures
    has_many :elements, through: :contents
    has_many :pages, through: :elements

    with_options(presence: true) do
      validates :name
    end
    validate :validate_file_attached

    scope :recent, -> { where("#{table_name}.created_at > ?", Time.current - 24.hours).order(:created_at) }
    scope :without_tag, -> { left_outer_joins(:taggings).where(gutentag_taggings: {id: nil}) }

    after_create_commit :downcase_blob_filename_extension_hack

    def self.searchable_alchemy_resource_attributes
      %w(name)
    end

    def self.last_upload
      Alchemy::ActiveStorageFile.joins(:file_blob).order(created_at: :desc).limit(1)
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

    # Needed for ATTACHMENT filter of content_type:
    #
    # def self.file_types_for_select
    #   TODO: Try this one:
    #   file_types = Alchemy::ActiveStorageFile.joins(:file_blob).select(:content_type).distinct
    #   PsydoCode:
    #   file_types = Alchemy::ActiveStorageFile...file.blob.pluck(:content_type)...uniq.map do |type|
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

    private

    def validate_file_attached
      errors.add(:file, :presence) unless file.attached?
    end

    # downcase the extension of the uploaded filename to avoid routing problem:
    # Alchemy routes are handled before activestorage routes and one alchemy route matches
    # everything that has NO format. Unfortunately, rails doesn't set e.g. png-format if the
    # extension is ".PNG" - it only handles lowercase extensions. Until that is "fixed"/
    # circumvented, we convert the file extension to lowercase letters.
    # Problem will still occur for file extensions Rails doesn't have a format for.
    def downcase_blob_filename_extension_hack
      if (name = file&.blob&.filename)
        file.blob.filename = File.basename(name) + File.extname(name).downcase
        file.blob.save!
      end
    end
  end
end
