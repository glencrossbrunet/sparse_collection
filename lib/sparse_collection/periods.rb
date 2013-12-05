module SparseCollection
  module Periods
    
    def periods_left(interval, attribute)
      # beginning mod(period_begin, interval)
      # ending mod(period_end, interval)
      
      # puts period

      count = 0
      total = 0
      groups = Hash.new{ |h, k| h[k] = {} }
      
      enum = durations_left.to_a
      until enum.empty?              
        pair = enum.first
        record, seconds = pair
        
        if seconds.zero?
          enum.shift
          next
        end
        
        # p pair
        
        secs = [interval - count, seconds].min
        count += secs
        total += secs
        seconds -= secs
        
        # puts "secs: #{secs}"
        # puts "count: #{count}"
        # puts "total: #{total}"
        # puts "seconds: #{seconds}"
        
        group_num = (total.to_i - 1) / interval
        groups[group_num].store record, secs
        
        # puts groups 
        
        if count == interval
          count = 0
        end

        pair[1] = seconds
      end
      
      groups.map do |num, durations|
        type = model.columns_hash[field.to_s].type
        datetime = (period_begin.to_time.utc + (interval * num.next)).send("to_#{type}")
        { field => datetime }.merge avgs(durations, [attribute], interval)
      end
    end
    
    private
    
    def mod(datetime, seconds)
      raw = datetime.to_time.round.to_i
      raw -= raw % seconds
      datetime = Time.at(raw).send("to_#{datetime.class.to_s.downcase}")
      datetime.respond_to?(:utc) ? datetime.utc : datetime
    end
    
    
    
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
    
  end
end