module SparseCollection
  module Intervals
    
    %w(left middle right).each do |precedence|
      define_method "intervals_#{precedence}" do |interval|
        intervals interval, &method("find_#{precedence}")
      end
    end
    
    private
    
    def intervals(interval)
      values = []
      period.step_with_duration(interval) do |time|
        record = yield time
        hash = HashWithIndifferentAccess.new record.try(:attributes)
        values << hash.merge(field => time)
      end
      values
    end
    
  end
end