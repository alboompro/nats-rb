require "nats/client"
require "concurrent-edge"

module BoomNats
  class Application
    attr_accessor :router, :nats_options
    attr_reader :route_topics

    def initialize
      @route_topics = []
      @subscriptions = []
      @callbacks = {
        before: [],
        after: []
      }

      @mutex = Mutex.new
    end

    def servers(value)
      stop
      @server = value
    end

    def draw_routes(&block)
      raise Error, "required block given" unless block_given?

      @router = BoomNats::Router.new(self)
      @router.setup(&block)
    end

    def setup(&block)
      instance_eval(&block) if block_given?
    end

    def nats
      NATS
    end

    def on_before(&block)
      @callbacks[:before] << block
    end

    def on_after(&block)
      @callbacks[:after] << block
    end

    def error_as_json(msg, topic, error)
      {
        message: msg,
        topic: topic,
        error: "#{error.class}: #{error.message}",
        backtrace: error.backtrace,
        status: "error"
      }.to_json
    end

    def start
      Thread.new do
        @callbacks[:before].each { |callback| callback.call(self) }

        nats_connect do |nats|
          @route_topics.each do |rt|
            @subscriptions << nats.subscribe(rt.topic, rt.options) do |msg, reply, _sub|
              rt.executor.new(msg, reply, nats, rt.serializer, rt.parser)
            rescue StandardError => e
              BoomNats.logger.error "BoomNats::error: #{e.message}"
              nats.publish(reply, error_as_json(msg, rt.topic, e)) unless reply.nil?
            end
          end

          BoomNats.logger.debug "BoomNats::started"

          prepare_trap unless defined?(Rails::Railtie)

          @callbacks[:after].each { |callback| callback.call(self) }
        end
      end

      wait unless defined?(Rails::Railtie)
    end

    def stop
      @subscriptions.each { |s| nats.unsubscribe(s) }
      @subscriptions = []

      # disconnect from old server if already configured
      if nats&.connected?
        nats.drain do
          nats.stop
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

    def execute(&block)
      timeout = Concurrent::Cancellation.timeout 5
      done = Concurrent::Channel.new(capacity: 1)
      Concurrent::Channel.go do
        loop do
          @mutex.synchronize do
            done << true if nats.connected?
          end

          done << false if timeout.origin.resolved?
        end
      end

      if ~done
        block.call(nats)
      else
        raise "Nats do not connected", BoomNats::Error
      end
    end

    protected

    def nats_connect(&block)
      NATS.start({
                   servers: @server,
                   **(nats_options.is_a?(Hash) ? nats_options : {})
                 }, &block)
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
