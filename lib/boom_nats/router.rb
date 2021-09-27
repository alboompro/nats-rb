module BoomNats
  class Router
    def initialize(application)
      @application = application
    end

    def setup(&block)
      instance_eval(&block)
    end

    def in_queue(name, &block)
      @current_group = name
      instance_eval(&block)
      @current_group = nil
    end

    def topic(name, klass, options = {})
      options = {
        queue: @current_group,
        **options
      }
      RouteTopic.new(@application).setup(name, klass, **options)
    end
  end
end
