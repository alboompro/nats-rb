require "nats/client"
require "concurrent-edge"

module BoomNats
  class Application
    attr_accessor :router, :nats_options
    attr_reader :route_topics, :nats

    def initialize
      @route_topics = []
      @subscriptions = []
      @mutex = Mutex.new
    end

    def servers(value)
      stop

      @nats = nats_connect(value)
    end

    def draw_routes(&block)
      raise Error, "required block given" unless block_given?

      @router = BoomNats::Router.new(self)
      @router.setup(&block)
    end

    def setup(&block)
      instance_eval(&block) if block_given?
    end

    def start
      @route_topics.each do |rt|
        @subscriptions << @nats.subscribe(rt.topic, rt.options) do |msg, reply, _sub|
          rt.executor.new(msg, reply, @nats, rt.serializer, rt.parser)
        end
      end

      BoomNats.logger.debug "BoomNats::started"

      return if defined?(Rails::Railtie)

      prepare_trap

      wait
    end

    def stop
      @subscriptions.each { |s| @nats.unsubscribe(s) }
      @subscriptions = []

      # disconnect from old server if already configured
      if @nats&.connected?
        @nats.drain do
          @nats.stop
        end
      end
    end

    def kill
      puts "exiting..." unless defined?(Rspec)
      sleep 1
      Thread.new do
        @mutex.synchronize do
          stop
          exit unless defined?(Rspec)
        end
      end
    end

    protected

    def nats_connect(servers)
      ch = Concurrent::Channel.new
      Concurrent::Channel.go do
        # Connect to NATS service
        NATS.start({
                     servers: servers,
                     **(nats_options.is_a?(Hash) ? nats_options : {})
                   }) do |nc|
          ch.put nc
        end
      end

      ch.take
    end

    def prepare_trap
      %w[INT TERM].each do |s|
        trap(s) { kill }
      end
    end

    def wait
      sleep
    end
  end
end
