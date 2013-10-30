require 'active_support/concern'

module SparseDatetime
  extend ActiveSupport::Concern

  module ClassMethods
    attr_accessor :sparse_attribute
    
    def sparse(attribute = :created_at)
      resources = where.not(attribute => nil).order("#{attribute} ASC")
      Collection.new resources, attribute
    end
  end
  
  class Collection
    attr_accessor :resources, :attribute
    
    def initialize(resources, attribute)
      self.resources = resources
      self.attribute = attribute
    end
    
    def self.avg(datetime_range)
      samples = where(sampled_at: datetime_range).order('sampled_at ASC')
    
      if samples.any?
        total_seconds = datetime_range.end.to_i - samples.first.sampled_at.to_i    
        average = 0.0
    
        samples.each_cons(2) do |start, stop|
          seconds = stop.sampled_at.to_i - start.sampled_at.to_i
          average += (seconds.to_f / total_seconds) * start.value
        end

        seconds = datetime_range.end.to_i - samples.last.sampled_at.to_i
        average += (seconds.to_f / total_seconds) * samples.last.value
    
        average
      else
        nil
      end
    end
    
    def riemann_left(field)
      return nil unless resources.any?
      
      period = (resources.last[attribute] - resources.first[attribute]).to_f
      total = 0.0
      
      resources.each_cons(2).map do |previous, current|
        sub_period = (current[attribute] - previous[attribute]).to_f
        total += previous[field] * sub_period
      end
      
      total / period
    end
    
    def riemann_right(field)
      return nil unless resources.any?
      
      period = (resources.last[attribute] - resources.first[attribute]).to_f
      total = 0.0
      
      resources.each_cons(2).map do |previous, current|
        sub_period = (current[attribute] - previous[attribute]).to_f
        total += current[field] * sub_period
      end
      
      total / period
    end
    
    def riemann_middle(field)
      return nil unless resources.any?
      
      period = (resources.last[attribute] - resources.first[attribute]).to_f
      total = 0.0
            
      resources.each_cons(2).map do |previous, current|
        sub_period = (current[attribute] - previous[attribute]).to_f
        multiplier = sub_period / 2
        total += multiplier * (previous[field] + current[field])
      end
      
      total / period
    end
    
  end
end