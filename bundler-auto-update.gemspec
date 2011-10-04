# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "bundler-auto-update/version"

Gem::Specification.new do |s|
  s.name        = "bundler-auto-update"
  s.version     = Bundler::AutoUpdate::VERSION
  s.authors     = ["Philippe Creux"]
  s.email       = ["pcreux@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{TODO: Write a gem summary}
  s.description = %q{TODO: Write a gem description}

  s.rubyforge_project = "bundler-auto-update"

  s.add_development_dependency "rspec"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
