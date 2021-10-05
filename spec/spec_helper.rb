# frozen_string_literal: true

require "simplecov"
SimpleCov.start do
  add_filter %r{^/spec/}
  add_filter %r{^/lib/generators}
end

require "boom_nats"

class NatsServerControl
  attr_reader :was_running, :uri
  alias was_running? was_running

  class << self
    def init_with_config(config_file)
      config = File.open(config_file) { |f| YAML.load(f) }
      uri = if auth = config["authorization"]
              "nats://#{auth["user"]}:#{auth["password"]}@#{config["net"]}:#{config["port"]}"
            else
              "nats://#{config["net"]}:#{config["port"]}"
            end
      NatsServerControl.new(uri, config["pid_file"], "-c #{config_file}")
    end

    def init_with_config_from_string(config_string, config = {})
      puts config_string if ENV["DEBUG_NATS_TEST"] == "true"
      config_file = Tempfile.new(["nats-cluster-tests", ".conf"])
      File.open(config_file.path, "w") do |f|
        f.puts(config_string)
      end

      uri = if auth = config["authorization"]
              "nats://#{auth["user"]}:#{auth["password"]}@#{config["host"]}:#{config["port"]}"
            else
              "nats://#{config["host"]}:#{config["port"]}"
            end

      NatsServerControl.new(uri, config["pid_file"], "-c #{config_file.path}", config_file)
    end
  end

  def initialize(uri = "nats://127.0.0.1:4222", pid_file = "/tmp/test-nats.pid", flags = nil, config_file = nil)
    @uri = uri.is_a?(URI) ? uri : URI.parse(uri)
    @pid_file = pid_file
    @flags = flags
    @config_file = config_file
  end

  def server_pid
    @pid ||= File.read(@pid_file).chomp.to_i
  end

  def server_mem_mb
    server_status = `ps axo pid=,rss= | grep #{server_pid}`
    parts = server_status.lstrip.split(/\s+/)
    rss = parts[1].to_i / 1024
  end

  def start_server(wait_for_server = true, monitoring: false)
    if NATS.server_running? @uri
      @was_running = true
      return 0
    end
    @pid = nil

    args = "-p #{@uri.port} -P #{@pid_file}"
    args += " -m 8222" if monitoring
    args += " --user #{@uri.user}" if @uri.user
    args += " --pass #{@uri.password}" if @uri.password
    args += " #{@flags}" if @flags

    if ENV["DEBUG_NATS_TEST"] == "true"
      system("nats-server #{args} -DV &")
    else
      system("nats-server #{args} 2> /dev/null &")
    end
    exitstatus = $?.exitstatus
    NATS.wait_for_server(@uri, 10) if wait_for_server # jruby can be slow on startup...
    exitstatus
  end

  def kill_server
    if File.exist? @pid_file
      `kill -9 #{server_pid} 2> /dev/null`
      `rm #{@pid_file} 2> /dev/null`
      sleep(0.1)
      @pid = nil
    end
  end
end

class A < BoomNats::Topic
  def consume
    { params: params }
  end
end

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
