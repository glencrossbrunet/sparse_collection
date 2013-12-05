module SparseCollection
  module Ensure

    def ensure_left(record, attribute)
      send :ensure, 'left', record, attribute
    end
    
    def ensure_right(record, attribute)      
      send :ensure, 'right', record, attribute
    end
    
    private
    
    def ensure(precedence, record, attribute)
      return false unless record.valid?
      
      precedent = send "find_#{precedence}", record.send(field)
      if precedent.present? && records_redundant?([ precedent, record ], attribute)
        precedent
      else
        record.save and record.reload
      end
    end
    
  end
end