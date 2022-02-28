# frozen_string_literal: true

module Alchemy
  VERSION = "5.0.10"

  def self.version
    VERSION
  end

  def self.gem_version
    Gem::Version.new(VERSION)
  end
end
