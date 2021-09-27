BoomNats.setup do
  servers "nats://localhost:4222"

  draw_routes do
    in_queue "queue_name" do
      topic "hello", HelloConsumer
    end
  end
end
