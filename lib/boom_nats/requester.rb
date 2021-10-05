module BoomNats
  module Requester
    def request(topic, params = nil, options = {})
      result = nil
      BoomNats.application.execute do |nats|
        timeout = Concurrent::Cancellation.timeout 5
        done = Concurrent::Channel.new(capacity: 1)
        Concurrent::Channel.go do
          nats.request(topic, params.to_json, options) do |msg|
            done << JSON.parse(msg)
          end
          timeout.origin.wait
          done << BoomNats::Error.new("request do not received")
        end
        result = ~done # block until signaled
      end
      raise result if result.is_a?(BoomNats::Error)

      result
    end
  end
end
