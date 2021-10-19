# frozen_string_literal: true

RSpec.describe BoomNats do
  before(:each) do
    BoomNats.logger = double("logger", debug: true, info: true, error: true, warn: true)
    allow_any_instance_of(BoomNats::Application).to receive(:wait)

    @s = NatsServerControl.new nats_server
    @s.start_server(true)
    allow_any_instance_of(Kernel).to receive(:exit)
    allow_any_instance_of(Kernel).to receive(:puts)
  end

  after(:each) do
    @s.kill_server
  end

  let(:nats_server) { "nats://#{ENV.fetch("NATS_HOST", "localhost")}:#{ENV.fetch("NATS_PORT", "4222")}" }

  it "has a version number" do
    expect(BoomNats::VERSION).not_to be nil
  end

  it "should setup the app with block" do
    expect(BoomNats.respond_to?(:setup)).to be_truthy
    BoomNats.setup
    expect(BoomNats.application).to be_instance_of BoomNats::Application
  end

  it "complete test execution" do
    server = nats_server
    BoomNats.setup do
      servers server
      draw_routes do
        in_queue "queue_name" do
          topic "topic_name", A
        end

        topic "topic_2", BoomNats::Topic
      end
    end

    BoomNats.application.start

    content = { "name" => "topic_name" }
    result = BoomNats.request "topic_name", content
    expect(result).to eql({ "params" => content })

    # - - - - - - - - -

    consume = spy("consume")
    allow_any_instance_of(A).to receive(:consume) do
      consume.consume
    end
    BoomNats.application.nats.publish "topic_name", "content"
    sleep 1
    expect(consume).to have_received(:consume)

    # - - - - - - - - -

    expect { BoomNats::Topic.new(nil, nil, nil, nil, nil).consume }.to raise_error BoomNats::Error

    BoomNats.application.kill
  end

  it "should execute callbacks correctly before/after application start" do
    server = nats_server
    beforeCallback = spy("beforeCallback")
    afterCallback = spy("afterCallback")

    BoomNats.setup do
      servers server
      on_before do |app|
        beforeCallback.call(app)
      end

      on_after do |app|
        afterCallback.call(app)
      end
    end

    BoomNats.application.start

    sleep 1

    expect(beforeCallback).to have_received(:call).with(BoomNats.application)
    expect(afterCallback).to have_received(:call).with(BoomNats.application)

    BoomNats.application.kill
  end
end
