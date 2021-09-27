# frozen_string_literal: true

RSpec.describe BoomNats do
  before(:each) do
    BoomNats.logger = double("logger", debug: true, info: true, error: true, warn: true)
    allow_any_instance_of(BoomNats::Application).to receive(:wait)

    @s = NatsServerControl.new
    @s.start_server(true)
    allow_any_instance_of(BoomNats::Application).to receive(:wait)
  end

  after(:each) do
    @s.kill_server
  end

  it "has a version number" do
    expect(BoomNats::VERSION).not_to be nil
  end

  it "should setup the app with block" do
    expect(BoomNats.respond_to?(:setup)).to be_truthy
    BoomNats.setup
    expect(BoomNats.application).to be_instance_of BoomNats::Application
  end

  it "complete test execution" do
    BoomNats.setup do
      servers "nats://localhost:4222"
      draw_routes do
        in_queue "queue_name" do
          topic "topic_name", A
        end

        topic "topic_2", BoomNats::Topic
      end
    end

    BoomNats.application.start

    ch = Concurrent::Channel.new capacity: 1
    allow_any_instance_of(A).to receive(:consume) do
      ch.put({ a: 1 })
    end
    Concurrent::Channel.go do
      BoomNats.application.nats.publish "topic_name", "content"
    end
    expect(ch.take).to eq({ a: 1 })

    ch = Concurrent::Channel.new capacity: 1
    allow_any_instance_of(A).to receive(:consume) do
      ch.put({ a: 2 })
      { a: 2 }
    end
    Concurrent::Channel.go do
      BoomNats.application.nats.request "topic_name", "content"
    end
    expect(ch.take).to eq({ a: 2 })

    expect { BoomNats::Topic.new(nil, nil, nil, nil, nil).consume }.to raise_error BoomNats::Error

    BoomNats.application.kill
  end
end
