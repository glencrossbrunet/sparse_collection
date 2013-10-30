require 'spec_helper'

describe SparseCollection::Collection do
  let(:resources) do
    resources = [
      { recorded_on: Date.parse('Jan 2, 2013'), value: 0 },
      # 1 day gap
      { recorded_on: Date.parse('Jan 3, 2013'), value: 5 },
      # 2 day gap
      { recorded_on: Date.parse('Jan 5, 2013'), value: 10 }
    ].map { |attributes| Resource.create(attributes) }
    Resource.where(id: resources.map(&:id))
  end
    
  let(:sparse) do
    resources.sparse(:recorded_on)
  end
  
  describe '#find' do
    describe '_left' do
      subject { sparse.find_left(date).try(:value) }
      
      describe 'no value' do
        let(:date) { Date.parse('Jan 1, 2013') }
        it { should be_nil }
      end
    
      describe 'exact match' do
        let(:date) { Date.parse('Jan 2, 2013') }
        it { should eq(0) }
      end
    
      describe 'in between' do
        let(:date) { Date.parse('Jan 4, 2013') }
        it { should eq(5) }
      end
    end
    
    describe '_right' do
      subject { sparse.find_right(date).try(:value) }
      
      describe 'no value' do
        let(:date) { Date.parse('Jan 6, 2013') }
        it { should be_nil }
      end
      
      describe 'exact match' do
        let(:date) { Date.parse('Jan 3, 2013') }
        it { should eq(5) }
      end
      
      describe 'in between' do
        let(:date) { Date.parse('Jan 4, 2013') }
        it { should eq(10) }
      end
    end
    
    describe '_middle' do
      subject { sparse.find_middle(date).try(:value) }
      
      describe 'early' do
        let(:date) { Date.parse('Jan 1, 2013') }
        it { should eq(0) }
      end
      
      describe 'late' do
        let(:date) { Date.parse('Jan 6, 2013') }
        it { should eq(10) }
      end
      
      describe 'tie goes to later' do
        let(:date) { Date.parse('Jan 4, 2013') }
        it { should eq(10) }
      end
    end
  end
  
  describe '#riemann' do    
    let(:delta) do
      0.00000001
    end
    
    describe '_left' do
      subject { sparse.average_left(:value) }
      sum = (1 * 0) + (2 * 5) + (0 * 10)
      it { should be_within(delta).of(sum / 3.0) }
    end
    
    describe '_middle' do
      subject { sparse.average_middle(:value) }
      sum = (0.5 * 0) + (0.5 * 5) + (1 * 5) + (1 * 10)
      it { should be_within(delta).of(sum / 3.0) }
    end
    
    describe '_right' do
      subject { sparse.average_right(:value) }
      sum = (0 * 0) + (1 * 5) + (2 * 10)
      it { should be_within(delta).of(sum / 3.0) }
    end
  end
end