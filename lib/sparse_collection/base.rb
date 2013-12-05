module SparseCollection
  class Base
    
    attr_accessor :records, :field
    attr_writer :period_begin, :period_end
    
    def initialize(records, field)
      raise ArgumentError, 'records required' if records.nil?
      raise ArgumentError, 'field required' if field.blank?
      
      self.records = records.where.not(field => nil).order("#{field} ASC")
      self.field = field
    end
    
    def beginning(period_begin)
      self.records = records.where("#{field} >= ?", period_begin)
      self.period_begin = period_begin
      self
    end
    
    def ending(period_end)
      self.records = records.where("#{field} <= ?", period_end)
      self.period_end = period_end
      self
    end
    
    def for(period)
      beginning(period.begin).ending(period.end)
    end
    
    def period_begin
      @period_begin ||= records.first.send(field)
    end
    
    def period_end
      @period_end ||= records.last.send(field)
    end
    
    def period
      period_begin..period_end
    end
    
    def period_duration
      seconds_between period_begin, period_end
    end
    
    def first
      records.first
    end
    
    def last
      records.last
    end
    
    def model
      records.model
    end
    
    private
    
    def duration_between(left, right)
      seconds_between left.send(field), right.send(field)
    end
    
    def seconds_between(earlier, later)
      (later.to_time - earlier.to_time).to_f
    end
    
  end
end