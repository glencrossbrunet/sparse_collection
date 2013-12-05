module SparseCollection
  module Find
    
    def find_left(datetime = nil)
      collection = records
      collection = collection.where("#{field} <= ?", datetime) unless datetime.nil?
      collection.reorder("#{field} DESC").limit(1).first
    end
    
    def find_middle(datetime)
      [ find_right(datetime), find_left(datetime) ].compact.min_by do |record|
        seconds_between(record.send(field), datetime).abs
      end
    end
    
    def find_right(datetime = nil)
      collection = records
      collection = records.where("#{field} >= ?", datetime) unless datetime.nil?
      collection.limit(1).first
    end
    
  end
end