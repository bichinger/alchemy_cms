# frozen_string_literal: true
module Alchemy
  class ActiveStorageFile < BaseRecord
    has_one_attached :file
  end
end
