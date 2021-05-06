# -*- encoding: utf-8 -*-
# frozen_string_literal: true

lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "hella-redis/version"

Gem::Specification.new do |gem|
  gem.name        = "hella-redis"
  gem.version     = HellaRedis::VERSION
  gem.authors     = ["Kelly Redding", "Collin Redding"]
  gem.email       = ["kelly@kellyredding.com", "collin.redding@me.com"]
  gem.summary     = "It's-a hella-redis!"
  gem.description = "It's-a hella-redis!"
  gem.homepage    = "http://github.com/redding/hella-redis"
  gem.license     = "MIT"

  gem.files         = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.required_ruby_version = "~> 2.5"

  gem.add_development_dependency("assert", ["~> 2.19.6"])
  gem.add_development_dependency("much-style-guide", ["~> 0.6.3"])

  gem.add_dependency("redis",           ["~> 3.2"])
  gem.add_dependency("redis-namespace", ["~> 1.5"])
  gem.add_dependency("connection_pool", ["=  0.9.2"]) # temp, for 1.8.7 support
end
