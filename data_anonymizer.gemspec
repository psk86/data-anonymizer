
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "data_anonymizer/version"

Gem::Specification.new do |spec|
  spec.name          = "data_anonymizer"
  spec.version       = DataAnonymizer::VERSION
  spec.authors       = ["Pranab"]
  spec.email         = ["pranab.khanal@gmail.com"]

  spec.summary       = %q{Anonymize Data}
  spec.description   = %q{Anonymize Data containing Personally Identifiable Information}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
end
