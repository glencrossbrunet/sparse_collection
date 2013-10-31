# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sparse_collection/version'

Gem::Specification.new do |spec|
  spec.name          = 'sparse_collection'
  spec.version       = SparseCollection::VERSION
  spec.authors       = %w(aj0strow)
  spec.email         = 'alexander.ostrow@gmail.com'
  spec.description   = 'Active Record Sparse Collection'
  spec.summary       = 'find the closest record and calculated averages over time periods'
  spec.homepage      = 'https://github.com/glencrossbrunet/sparse_collection'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.test_files    = spec.files.grep(/spec/)
  spec.require_paths = %w(lib)

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'activerecord'
  spec.add_development_dependency 'sqlite3'
end