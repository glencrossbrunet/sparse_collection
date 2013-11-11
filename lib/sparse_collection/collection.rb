module SparseCollection
  class Collection
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
      
      total = 0.0
      
      total += each_pair do |left, right, sub_period|
        left[field] * sub_period
      end
      
      last = resources.last
      total += period_between(last[attribute], period_end) * last[field]
      
      total / period_duration
    end
    
    def average_right(field)
      return nil unless resources.any?
      return resources.last[field] if resources.count == 1
      
      total = 0.0
      
      first = resources.first
      total += period_between(period_start, first[attribute]) * first[field]
      
      total += each_pair do |left, right, sub_period|
        right[field] * sub_period
      end
      
      total / period_duration
    end
    
    def average_middle(field)
      return nil unless resources.any?
      return resources.average(field) if resources.count == 1
      
      total = 0.0
      
      total += each_pair do |left, right, sub_period|
        (sub_period / 2) * (left[field] + right[field])
      end
      
      total / period_duration
    end
    
    def each_pair
      resources.each_cons(2).reduce(0.0) do |sum, pair|
        sub_period = period_between pair.first[attribute], pair.last[attribute]
        sum + yield(*pair, sub_period)
      end
    end
    
    def period_duration
      period_between(period_start, period_end)
    end
    
    def period_between(left, right)
      (right.to_time - left.to_time).to_f
    end
    
    
    # find
    
    
    def find_left(datetime = nil)
      collection = resources
      collection = collection.where("#{attribute} <= ?", datetime) if datetime
      collection.order("#{attribute} DESC").limit(1).first
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
		
		
		def prune_left(field, delta = nil)
			return resources if resources.count < 2
			
			precedent = nil
			resources.each_cons(2) do |left, right|
				precedent = left if left.persisted?
				records = [ precedent, right ]
				right.destroy if records_redundant? records, field, delta
			end
			resources.reload
		end
		
		def prune_middle(field, delta = nil)
			return resources if resources.count < 3
			
			precedent = nil
			resources.each_cons(3) do |left, middle, right|
				precedent = left if left.persisted?
				records = [ precedent, middle, right ]
				middle.destroy if records_redundant? records, field, delta
			end
			resources.reload
		end
		
		def prune_right(field, delta = nil)
			return resources if resources.count < 2
			
			precedent = nil
			resources.reverse_each.each_cons(2) do |right, left|
				precedent = right if right.persisted?
				records = [ precedent, left ]
				left.destroy if records_redundant? records, field, delta
			end
			resources.reload
		end
		
		def records_redundant?(records, field, delta = nil)
			values = records.map{ |record| record[field] }
			values_redundant? values, delta
		end
		
		def values_redundant?(values, delta = nil)
			values.combination(2).all? do |a, b|
				if delta.nil? then a == b else (a - b).abs <= delta end
			end
		end
    
  end
end