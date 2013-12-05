require 'rubygems'
require 'bundler/setup'
require 'active_record'
require 'sparse_collection'

ActiveRecord::Base.establish_connection adapter: 'sqlite3',
  database: 'spec/testdb.sqlite'

ActiveRecord::Migration.class_eval do
  create_table :resources, force: true do |t|
    t.date :recorded_on
    t.datetime :recorded_at
    t.integer :value
    t.string :status
    t.timestamps
  end
end

class Resource < ActiveRecord::Base
  extend SparseCollection
  
  def val
    value
  end
end

module Helpers
  def delta
    0.00000001
  end
end

RSpec.configure do |config|
  config.include Helpers
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
  config.order = 'random'
end