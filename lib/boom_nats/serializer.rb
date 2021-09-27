require "json"

module BoomNats::Serializer
  JSONSerializer = JSON.method(:generate)
  JSONParser = JSON.method(:parse)

  mattr_accessor :default_serializer, :default_parser
end
