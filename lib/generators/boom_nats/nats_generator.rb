class BoomNats::InstallGenerator < Rails::Generators::NamedBase
  source_root File.expand_path("templates", __dir__)

  desc " asdasdasd "
  def install
    copy_file "initializer.rb", "config/initializers/boom_nats.rb"
    create_file "app/consumers/hello_consumer.rb", <<~FILE
      class HelloConsumer < BoomNats::Topic
        def consume
          { message: "Hello \#{params["name"]}, how are you?" }
        end
      end
    FILE
  end

  desc " asdasdasd sadasda"
  def consumer
    puts "asd: #{asd}"
  end
end
