class BoomNats::ConsumerGenerator < Rails::Generators::NamedBase
  source_root File.expand_path("templates", __dir__)

  desc " asdasdasd "
  def create_consumer_class
    create_file "app/consumers/#{file_name}_consumer.rb", <<~FILE
      class #{class_name}Consumer < BoomNats::Topic
        def consume
          { message: "Hello \#{params["name"]}, how are you?" }
        end
      end
    FILE
  end
end
