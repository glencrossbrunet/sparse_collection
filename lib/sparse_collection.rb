require 'sparse_collection/core_ext/range'
%w(version base find durations averages intervals ensure prune).each do |f|
  require "sparse_collection/#{f}"
end 

module SparseCollection
  
  def sparse(field = :created_at)
    ::SparseCollection::Base.new self, field
  end
  
  class Base
    include Find
    include Durations
    include Averages
    include Intervals
    include Ensure
    include Prune
  end
  
end