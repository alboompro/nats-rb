# BoomNats

NATS is a simple, secure and performant communications system for digital systems, services and devices. NATS is part of the Cloud Native Computing Foundation (CNCF). See more on [Github NATS](https://github.com/nats-io/nats-server).

This implementation works in both modes: Standalone and Rails based applications.

## Documentation
- [Configurations](#configurations)
- [Rails](#rails)
  - [Installing](#rails-installing)
  - [Configuration](#rails-configuration)
- [Standalone](#standalone)
  - [Installing](#standalone-installing)
  - [Configuration](#standalone-configuration)
  - [Starting Application](#standalone-starting-application)
## configurations

```ruby
require 'boom_nats'
# require_relative "consumers/...."

BoomNats.setup do
  # basic NATS service
  servers "nats://127.0.0.1:4222"

  # Clustering NATS
  servers ["nats://nats1:4222", "nats://nats2:4222"]

  # with authentication
  servers "nats://user:pass@localhost:4222"
  

  # map NATS topics to Topic classes
  draw_routes do
    topic "topic-name", MyTopic
    topic "namespace.topic", NamespacedTopic
    topic "topic-queued", QueuedTopic, queue: 'queue-name'

    # many topics queueds
    in_queue "queue-name" do
      topic "topic-queued", QueuedTopic
    end

    # auto unsubscribe after N messages
    topic "auto-unsubscribe", TmpTopic, options: { max: 1 }
  end
end

# start application
BoomNats.application.start
```

## Rails

To facilitate learning, you can download the default repository containing a boilerplate project with (Rails + Nats)

```bash
git clone https://github.com/alboompro/boomnats-rails-example.git
```

See details on [BoomNats Rails Project](https://github.com/alboompro/boomnats-rails-example)

### Rails Installing

Add GEM to Gemfile

```ruby
gem 'boom_nats', '~> 0.1.0'
```

### Rails Configuration

Using the generators to configure app, after create rails app

```bash
rails g boom_nats:install
# create files:
# app/consumers/hello_consumer.rb
# config/initializers/boom_nats.rb
```

Create consumers with generators too

```bash
rails g boom_nats:consumer PaymentGetter
# creates file: app/consumers/payment_getter_consumer.rb
```


## Standalone

To facilitate learning, you can download the default repository containing a boilerplate project with (Ruby, Nats and ActiveRecord)

```bash
git clone https://github.com/alboompro/boomnats-standard-example.git
```

See details on [BoomNats Standard Project](https://github.com/alboompro/boomnats-standard-example)

### Standalone Installing

Download de GEM with the following command:

```bash
gem install boom_nats
```

With bundle, add gem to Gemfile

```ruby
gem 'boom_nats', '~> 0.1.0'
```

### Standalone Configuration

Create a simple file `boom_nats.rb` and put this content:

```ruby
require "boom_nats"

class MyTopic < BoomNats::Topic
  def consume
    {
      hello: params["name"]
    }
  rescue StandardError => e
    puts e.message
  end
end

BoomNats.setup do
  servers "nats://127.0.0.1:4222"

  draw_routes do
    topic "hello", MyTopic
  end
end

BoomNats.application.start
```

### Standalone Starting Application

```bash
ruby boom_nats.rb
```
