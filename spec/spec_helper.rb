require 'rubygems'
require 'bundler/setup'
require 'active_record'
require 'sparse_collection'

ActiveRecord::Base.establish_connection adapter: 'sqlite3',
  database: 'spec/testdb.sqlite'

ActiveRecord::Migration.class_eval do
  drop_table :resources

  create_table :resources do |t|
    t.date :recorded_on
    t.datetime :recorded_at
    t.integer :value
    t.timestamps
  end
end

class Resource < ActiveRecord::Base
  extend SparseCollection
end

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
  config.order = 'random'
end