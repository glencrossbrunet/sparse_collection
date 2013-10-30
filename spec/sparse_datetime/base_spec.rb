require 'spec_helper'

describe Resource do
  describe '#sparse' do
    subject { Resource.all.sparse }
    it { should be_a(SparseDatetime::Collection) }
  end
  
  describe '#riemann' do
    let(:resources) do
      resources = [
        { recorded_on: Date.parse('Jan 1, 2013'), int_value: 0 },
        # 1 day gap
        { recorded_on: Date.parse('Jan 2, 2013'), int_value: 5 },
        # 2 day gap
        { recorded_on: Date.parse('Jan 4, 2013'), int_value: 10 }
      ].map { |attributes| Resource.create(attributes) }
      Resource.where(id: resources.map(&:id))
    end
    
    let(:sparse) do
      resources.sparse(:recorded_on)
    end
    
    let(:delta) do
      0.00000001
    end
    
    describe 'right' do
      subject { sparse.riemann_right(:int_value) }
      sum = (0 * 0) + (1 * 5) + (2 * 10)
      it { should be_within(delta).of(sum / 3.0) }
    end
    
    describe 'left' do
      subject { sparse.riemann_left(:int_value) }
      sum = (1 * 0) + (2 * 5) + (0 * 10)
      it { should be_within(delta).of(sum / 3.0) }
    end
    
    describe 'middle' do
      subject { sparse.riemann_middle(:int_value) }
      sum = (0.5 * 0) + (0.5 * 5) + (1 * 5) + (1 * 10)
      it { should be_within(delta).of(sum / 3.0) }
    end
  end
end