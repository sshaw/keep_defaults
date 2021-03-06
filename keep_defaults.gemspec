
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "keep_defaults/version"

Gem::Specification.new do |spec|
  spec.name          = "keep_defaults"
  spec.version       = KeepDefaults::VERSION
  spec.authors       = ["sshaw"]
  spec.email         = ["skye.shaw@gmail.com"]

  spec.summary       = %q{Prevent ActiveRecord attributes for `not null` columns with default values from being set to `nil`}
  spec.description   =<<-DESC
    Prevent ActiveRecord attributes for not null columns with default values from being set to nil.
    Instead of setting/returning nil the column's default value is returned.
  DESC
  spec.homepage      = "https://github.com/sshaw/keep_defaults"
  spec.license       = "MIT"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "activerecord", ">= 4.2", "< 7"

  spec.add_development_dependency "appraisal"
  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
