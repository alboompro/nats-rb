module BoomNats
  class RouteTopic
    attr_reader :topic, :executor, :queue, :serializer, :parser, :options

    def initialize(application)
      @application = application
    end

    def setup(topic_name, executor, serializer: nil, parser: nil, queue: nil, options: nil)
      @topic = topic_name
      @executor = executor
      @serializer = default_serializer(serializer)
      @parser = default_parser(parser)
      @queue = queue
      @options = default_options(options, queue)

      subscribe
    end

    protected

    def default_parser(parser)
      [
        parser,
        BoomNats::Serializer.default_parser
      ].each do |entry|
        return entry if entry.respond_to? :call
      end
      BoomNats::Serializer::JSONParser
    end

    def default_serializer(serializer)
      [
        serializer,
        BoomNats::Serializer.default_serializer
      ].each do |entry|
        return entry if entry.respond_to? :call
      end
      BoomNats::Serializer::JSONSerializer
    end

    def default_options(options = {}, queue = nil)
      {
        queue: queue,
        max: nil,
        **(options.is_a?(Hash) ? options : {})
      }
    end

    def subscribe
      @application.route_topics << self
    end
  end
end
