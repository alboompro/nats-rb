module BoomNats
  class Railtie < Rails::Railtie
    initializer "activeservice.autoload", before: :set_autoload_paths do |app|
      # app.config.autoload_paths << ActiveService::Configuration.path
      app.config.eager_load_paths << Rails.root.join("app", "consumers").to_s
    end

    initializer "boom_nats.railtie.configure_rails_initialization" do |app|
      app.config.nats = BoomNats.setup
      BoomNats.logger = Rails.logger
    end

    server do |app|
      app.config.nats.start
    end
  end
end
