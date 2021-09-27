# frozen_string_literal: true

require "zeitwerk"
require "logger"
require "active_support/core_ext/module/attribute_accessors"

loader = Zeitwerk::Loader.for_gem
loader.setup

module BoomNats
  class Error < StandardError; end

  extend BoomNats::Serializer
  extend BoomNats::Setup

  mattr_accessor :logger
end

BoomNats.logger = Logger.new(STDOUT)

require "boom_nats/railtie" if defined?(Rails::Railtie)
