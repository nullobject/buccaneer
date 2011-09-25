# encoding: utf-8

$:.push File.expand_path("../lib", __FILE__)

require "bucaneer/version"

Gem::Specification.new do |s|
  s.name        = "bucaneer"
  s.version     = Bucaneer::VERSION
  s.author      = "Josh Bassett"
  s.email       = "josh.bassett@gmail.com"
  s.homepage    = "http://github.com/nullobject/bucaneer"
  s.summary     = %q{BusPirate library for Ruby.}
  s.description = %q{Bucaneer is a Ruby library which allows you to control your BusPirate bitbang modes (I2C, SPI, etc).}

  s.rubyforge_project = "bucaneer"

  s.files       = `git ls-files`.split("\n")
  s.test_files  = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables = `git ls-files -- bin/*`.split("\n").map {|f| File.basename(f) }

  s.add_development_dependency "rr"
  s.add_development_dependency "rspec"
  s.add_development_dependency "simplecov"

  s.add_runtime_dependency "serialport"
end
