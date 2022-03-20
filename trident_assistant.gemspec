# frozen_string_literal: true

require_relative "lib/trident_assistant/version"

Gem::Specification.new do |spec|
  spec.name          = "trident_assistant"
  spec.version       = TridentAssistant::VERSION
  spec.authors       = ["an-lee"]
  spec.email         = ["an.lee.work@gmail.com"]

  spec.summary       = "A simple program to use Trident NFT"
  spec.description   = "A simple program to use Trident NFT"
  spec.homepage      = "https://github.com/TheTridentOne/trident_assistant"
  spec.license       = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  # spec.metadata["allowed_push_host"] = "TODO: Set to your gem server 'https://example.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/TheTridentOne/trident_assistant"
  spec.metadata["changelog_uri"] = "https://github.com/TheTridentOne/trident_assistant"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "mixin_bot", "~> 0.8"

  # For more information and examples about making a new gem, checkout our
  # guide at: https://bundler.io/guides/creating_gem.html
  spec.metadata["rubygems_mfa_required"] = "true"
end
