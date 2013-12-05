class Range
  def step_with_duration(step_size = 1, &block)
    return to_enum(:step, step_size) unless block_given?

    parts = Hash[step_size.parts]

    time = self.begin
    while exclude_end? ? time < self.end : time <= self.end
      yield time
      time = time.advance parts
    end
  end

end