# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'pushover/version'

Gem::Specification.new do |gem|
  gem.name          = "pushover"
  gem.version       = Pushover::VERSION
  gem.authors       = ["Jon Neverland"]
  gem.email         = ["jonwestin@gmail.com"]
  gem.description   = %q{Thor-based CLI for Pushover. Send notifications!}
  gem.summary       = %q{Thor-based CLI for Pushover. Send notifications!}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
end
