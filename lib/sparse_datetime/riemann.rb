module SparseDatetime
  module Riemann
    
    def riemann_left(field)
      return nil unless resources.any?
      
      total = 0.0
      
      total += each_pair do |left, right, sub_period|
        left[field] * sub_period
      end
      
      last = resources.last
      total += (period_end - last[attribute]).to_f * last[field]
      
      total / period
    end
    
    def riemann_right(field)
      return nil unless resources.any?
      
      total = 0.0
      
      first = resources.first
      total += (first[attribute] - period_start).to_f * first[field]
      
      total += each_pair do |left, right, sub_period|
        right[field] * sub_period
      end
      
      total / period
    end
    
    def riemann_middle(field)
      return nil unless resources.any?
      
      total = 0.0
      
      total += each_pair do |left, right, sub_period|
        (sub_period / 2) * (left[field] + right[field])
      end
      
      total / period
    end
    
    def each_pair
      resources.each_cons(2).reduce(0.0) do |sum, pair|
        period = (pair.last[attribute] - pair.first[attribute]).to_f
        sum + yield(*pair, period)
      end
    end
    
  end
end