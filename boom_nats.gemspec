# frozen_string_literal: true

require_relative "lib/boom_nats/version"

Gem::Specification.new do |spec|
  spec.name          = "boom_nats"
  spec.version       = BoomNats::VERSION
  spec.authors       = ["Welington Sampaio"]
  spec.email         = ["welington.sampaio@outlook.com"]

  spec.summary       = "Native NATS integration server to standalone or Rails based app"
  spec.description   = "Create ruby server or integrates with a Rails app to integrate NATS messages consumer"
  spec.homepage      = "https://opensource.alboompro.com/#alboom-nats-rb"
  spec.license       = "MIT"
  spec.required_ruby_version = ">= 2.5.0"

  # spec.metadata["allowed_push_host"] = "TODO: Set to 'https://mygemserver.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/alboompro/alboom-nats-rb"
  spec.metadata["changelog_uri"] = "https://github.com/alboompro/alboom-nats-rb/master/Changelog"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  spec.add_dependency "activesupport", ">= 2.1"
  spec.add_dependency "concurrent-ruby-edge", "~> 0.6", "< 1.0"
  spec.add_dependency "nats", ">= 0.11.0", "< 1.0"
  spec.add_dependency "rack", "~> 2.0", ">= 2.0.9"
  spec.add_dependency "zeitwerk", ">= 2.0", "< 3.0"

  # For more information and examples about making a new gem, checkout our
  # guide at: https://bundler.io/guides/creating_gem.html
end
