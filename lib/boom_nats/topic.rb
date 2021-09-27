module BoomNats
  class Topic
    def initialize(message, reply_to, nats, serializer, parser)
      @message = message
      @reply_to = reply_to
      @nats = nats
      @serializer = serializer
      @parser = parser

      start
    end

    def consume
      raise Error, "consume method do not implement yet"
    end

    protected

    def start
      @result = consume

      unless @reply_to.nil?
        # puts "ReplyTo(#{@reply_to}) with: #{parsed_result}"
        @nats.publish(@reply_to, parsed_result)
      end

      @result
    end

    def params
      @params ||= parsed_message
    end

    def parsed_message
      @parser.call(@message)
    end

    def parsed_result
      @serializer.call(@result)
    end
  end
end
