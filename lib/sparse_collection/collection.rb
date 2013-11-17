module SparseCollection
  class Collection
    attr_accessor :resources, :attribute, :period_start, :period_end
    
    def initialize(resources, attribute)
      self.resources = resources.order("#{attribute} ASC")
      self.attribute = attribute
      if resources.any?
        starting resources.first[attribute]
        ending resources.last[attribute]
      end
    end
    
    def starting(datetime)
      self.period_start = datetime
      self
    end
    alias_method :beginning, :starting
    
    def ending(datetime)
      self.period_end = datetime
      self
    end
    
    
    # average
    
    
    def average_left(field)
      return nil unless resources.any?
      return resources.first[field] if resources.count == 1
      
      durations = duration_left(resources, period_end)
      sum(durations, field) / period_duration
    end
    
    def average_right(field)
      return nil unless resources.any?
      return resources.last[field] if resources.count == 1
      
      durations = duration_right(resources, period_start)
      sum(durations, field) / period_duration
    end
    
    def average_middle(field)
      return nil unless resources.any?
      return resources.average(field) if resources.count == 1

      durations = duration_middle(resources)
      sum(durations, field) / period_duration
    end
    
    def sum(durations, field)
      durations.reduce(0.0) do |sum, pair|
        record, seconds = pair
        sum + record[field] * seconds
      end
    end
    
    def period_duration
      period_between period_start, period_end
    end
    
    def period_between(earlier, later)
      (later.to_time - earlier.to_time).to_f
    end
    
    def duration_between(left, right)
      period_between left[attribute], right[attribute]
    end
    
    
    # find
    
    
    def find_left(datetime = nil)
      collection = resources
      collection = collection.where("#{attribute} <= ?", datetime) if datetime
      collection.reorder("#{attribute} DESC").limit(1).first
    end
    
    def find_middle(datetime)
      [ find_right(datetime), find_left(datetime) ].compact.min_by do |resource|
        period_between(resource[attribute], datetime).abs
      end
    end
    
    def find_right(datetime = nil)
      collection = resources
      collection = collection.where("#{attribute} >= ?", datetime) if datetime
      collection.order("#{attribute} ASC").limit(1).first
    end
    
    
    # prune
    
    
    def prune_left(field)
      return resources if resources.count < 2
            
      resources.each_cons(2, &prune_proc(field))
      resources.reload
    end
    
    def prune_middle(field)
      return resources if resources.count < 3
            
      resources.each_cons(3, &prune_proc(field))
      resources.reload
    end
    
    def prune_right(field)
      return resources if resources.count < 2
            
      resources.reverse_each.each_cons(2, &prune_proc(field))
      resources.reload
    end
    
    def prune_proc(field)
      true_precedent = nil
      proc do |precedent, record, *rest|
        true_precedent = precedent if precedent.persisted?
        records = [ true_precedent, record, *rest ]
        record.destroy if records_redundant? records, field
      end
    end
    
    def records_redundant?(records, field)
      field, delta = [ *field ].first
      values = records.map{ |record| record[field] }
      values_redundant? values, delta
    end
    
    def values_redundant?(values, delta)
      values.combination(2).all? do |a, b|
        if delta.nil? then a == b else (a - b).abs <= delta end
      end
    end
    
    # ensure
    
    def ensure_left(resource, field)
      return false unless resource.valid?
      
      precedent = find_left resource[attribute]
      ensure_record precedent, resource, field
    end
    
    def ensure_right(resource, field)
      return false unless resource.valid?
      
      precedent = find_right resource[attribute]
      ensure_record precedent, resource, field
    end
    
    def ensure_record(precedent, resource, field)
      if precedent.present? && records_redundant?([ precedent, resource ], field)
        precedent
      else
        resource.save and resource.reload
      end
    end
    
    # regularize
    
    def regularize_left(period, field)    
      groups = resources.group_by do |resource|
        seconds = period_between(period_start, resource[attribute])
        (seconds / period).ceil
      end
      
      previous = { field => nil }     
      
      (0..period_duration.to_i).step(period).with_index.map do |seconds, index|
        time = period_start.advance(seconds: seconds)
        records = groups[index]
        
        value = if records.nil?
          previous[field]
        elsif records.one?
          records.first[field]
        else
          total = sum(duration_left(records, time), field)
          total / period_between(records.first[attribute], time)
        end
        
        previous = records.last unless records.nil?
                
        { attribute => time, field => value }
      end
    end
    
    # duration
    
    def duration_left(records, period_stop)
      seconds = {}
      records.each_cons(2) do |left, right|
        seconds[left] = duration_between left, right
      end
      seconds[records.last] = period_between records.last[attribute], period_stop
      seconds
    end
    
    def duration_middle(records)
      seconds = Hash.new{ |h, k| h[k] = 0.0 }
      records.each_cons(2) do |pair|
        period = duration_between(*pair) / 2
        pair.each { |record| seconds[record] += period }
      end
      seconds
    end
    
    def duration_right(records, period_start)
      seconds = {}
      seconds[records.first] = period_between period_start, records.first[attribute]
      records.each_cons(2) do |left, right|
        seconds[right] = duration_between left, right
      end
      seconds
    end
    
  end
end