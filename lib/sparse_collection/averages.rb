module SparseCollection
  module Averages
    
    %w(left middle right).each do |precedent|
      define_method "averages_#{precedent}" do |*attributes|
        averages attributes, &method("durations_#{precedent}")
      end
      
      define_method "average_#{precedent}" do |attribute|
        average attribute, &method("durations_#{precedent}")
      end
    end
    
    private
    
    def averages(attributes)
      return nil unless records.any?
      return first.attributes.slice(*attributes) if records.count == 1
      
      durations = yield
      avgs durations, attributes, period_duration
    end
    
    def average(attribute)
      return nil unless records.any?
      return first.send(attribute) if records.count == 1
      
      durations = yield
      avg durations, attribute, period_duration
    end
    
    def avgs(durations, attributes, seconds)
      attributes.each_with_object({}) do |attribute, hash|
        hash[attribute] = avg(durations, attribute, seconds)
      end
    end
    
    def avg(durations, attribute, seconds)
      sum(durations, attribute) / seconds
    end
    
    def sum(durations, attribute)      
      durations.reduce(0.0) do |sum, pair|
        record, seconds = pair
        sum + record.send(attribute) * seconds
      end
    end
    
  end
end