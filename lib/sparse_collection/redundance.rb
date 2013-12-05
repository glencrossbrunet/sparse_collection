module SparseCollection
  module Redundance
    
    def redundant_left?(record, attribute)
      redundant? :left, record, attribute
    end
    
    def redundant_right?(record, attribute)
      redundant? :right, record, attribute
    end
    
    def redundant?(precedence, record, attribute)
      precedent = send "find_#{precedence}", record.send(field)
      precedent.present? && records_redundant?([ precedent, record ], attribute)
    end
    
    def records_redundant?(records, attribute)
      attribute, delta = [ *attribute ].first
      values = records.map{ |record| record.send(attribute) }
      values.combination(2).all? do |a, b|
        if delta.nil? then a == b else (a - b).abs <= delta end
      end
    end
    
  end
end