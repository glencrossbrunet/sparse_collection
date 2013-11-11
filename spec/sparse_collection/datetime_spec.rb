require 'spec_helper'

describe 'Collection with datetimes' do
  
  let(:resources) do    
    resources = [
      { recorded_at: DateTime.new(2013, 1, 1, 2), value: 0 },
      # 1 day gap
      { recorded_at: DateTime.new(2013, 1, 1, 3), value: 5 },
      # 2 day gap
      { recorded_at: DateTime.new(2013, 1, 1, 5), value: 10 }
    ].map { |attributes| Resource.create(attributes) }
    Resource.where(id: resources.shuffle.map(&:id))
  end
    
  let(:sparse) do
    resources.sparse(:recorded_at)
  end
  
  let(:delta) do
    0.00000001
  end
  
  describe '#average_left' do    
    subject { sparse.average_left(:value) }
    sum = (1 * 0) + (2 * 5) + (0 * 10)
    it { should be_within(delta).of(sum / 3.0) }
  end
    
  describe 'ending' do
    subject { sparse.ending(DateTime.new(2013, 1, 1, 6)).average_left(:value) }
    sum = (1 * 0) + (2 * 5) + (1 * 10)
    it { should be_within(delta).of(sum / 4.0) }
  end
  
  describe '#average_middle' do
    subject { sparse.average_middle(:value) }
    sum = (0.5 * 0) + (0.5 * 5) + (1 * 5) + (1 * 10)
    it { should be_within(delta).of(sum / 3.0) }
  end
  
  describe '#average_right' do
    subject { sparse.average_right(:value) }
    sum = (0 * 0) + (1 * 5) + (2 * 10)
    it { should be_within(delta).of(sum / 3.0) }
  end
  
  describe 'starting' do
    subject { sparse.starting(DateTime.new(2013, 1, 1, 1)).average_right(:value) }
    sum = (1 * 0) + (1 * 5) + (2 * 10)
    it { should be_within(delta).of(sum / 4.0) }
  end
end
