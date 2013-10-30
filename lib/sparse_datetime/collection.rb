require 'sparse_datetime/riemann'

module SparseDatetime
  class Collection
    include Riemann
    
    attr_accessor :resources, :attribute, :period_start, :period_end
    
    def initialize(resources, attribute)
      self.resources = resources
      self.attribute = attribute
      if resources.any?
        starting resources.first[attribute]
        ending resources.last[attribute]
      end
    end
    
    def starting(datetime)
      self.period_start = datetime
    end
    alias_method :beginning, :starting
    
    def ending(datetime)
      self.period_end = datetime
    end
    
    def period
      (period_end - period_start).to_f
    end
  end
end