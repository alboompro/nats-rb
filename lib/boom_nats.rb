# frozen_string_literal: true

require "zeitwerk"
require "logger"
require "active_support/core_ext/module/attribute_accessors"

loader = Zeitwerk::Loader.for_gem
loader.setup
loader.ignore("#{__dir__}/boom_nats/railtie.rb")
loader.ignore("#{__dir__}/generators/**/*.rb")

module BoomNats
  class Error < StandardError; end

  extend BoomNats::Serializer
  extend BoomNats::Setup
  extend BoomNats::Requester

  mattr_accessor :logger
end

BoomNats.logger = Logger.new(STDOUT)

require "boom_nats/railtie" if defined?(::Rails::Railtie)
