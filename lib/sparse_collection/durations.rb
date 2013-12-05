module SparseCollection
  module Durations
    
    def durations_left
      seconds = Hash.new(0)
      return seconds unless records.any?
      
      if period_begin < first.send(field)
        left = model.sparse(field).find_left period_begin
        seconds[left] = seconds_between period_begin, first.send(field) unless left.nil?        
      end
      
      records.each_cons(2) do |left, right|
        seconds[left] = duration_between left, right
      end
      
      seconds[last] = seconds_between last.send(field), period_end
      seconds
    end
    
    def durations_middle
      seconds = Hash.new(0)
      return seconds unless records.any?
      
      seconds[first] = seconds_between period_begin, first.send(field)
      
      records.each_cons(2) do |pair|
        duration = duration_between(*pair) / 2
        pair.each { |record| seconds[record] += duration }
      end
      
      seconds[last] += seconds_between last.send(field), period_end
      seconds
    end
    
    def durations_right
      seconds = Hash.new(0)
      return seconds unless records.any?
      
      seconds[first] = seconds_between period_begin, first.send(field)
      
      records.each_cons(2) do |left, right|
        seconds[right] = duration_between left, right
      end
      
      if last.send(field) < period_end
        right = model.sparse(field).find_right period_end
        seconds[right] = seconds_between last.send(field), period_end unless right.nil?
      end
      seconds
    end
    
  end
end