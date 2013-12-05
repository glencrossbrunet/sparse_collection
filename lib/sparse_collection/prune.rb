module SparseCollection
  module Prune
    
    def prune_left(attribute)
      prune(records, 2, attribute)
    end
    
    def prune_middle(attribute)
      prune(records, 3, attribute)
    end
    
    def prune_right(attribute)
      prune(records.reverse_each, 2, attribute)
    end
    
    def prune(enum, batch_size, attribute)
      return records if records.count < batch_size
      
      true_precedent = nil
      enum.each_cons(batch_size) do |precedent, record, *rest|
        true_precedent = precedent if precedent.persisted?
        records = [ true_precedent, record, *rest ]
        record.destroy if records_redundant? records, attribute
      end
      records.reload
    end
    
  end
end