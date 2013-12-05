require 'sparse_collection/core_ext/range'
Dir.chdir(File.dirname __FILE__) do
  Dir.glob('sparse_collection/*.rb'){ |f| require f }
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
    include Redundance
    include Ensure
    include Prune
  end
  
end