require 'spec_helper'

describe 'Collection#average' do
  let(:resources) do
    resources = [
      { recorded_on: Date.parse('Jan 2, 2013'), recorded_at: DateTime.new(2013, 1, 1, 2), value: 0 },
      # 1 day / hour gap
      { recorded_on: Date.parse('Jan 3, 2013'), recorded_at: DateTime.new(2013, 1, 1, 3), value: 5 },
      # 2 day / hour gap
      { recorded_on: Date.parse('Jan 5, 2013'), recorded_at: DateTime.new(2013, 1, 1, 5), value: 10 }
    ].map { |attributes| Resource.create(attributes) }
    Resource.where(id: resources.map(&:id))
  end

  let(:delta) do
    0.00000001
  end
	
	context 'date' do
	  let(:sparse) do
	    resources.sparse(:recorded_on)
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
    
	  describe 'over 0 length range' do
	    let(:sparse) { resources.where(recorded_on: Date.parse('Jan 3, 2013')).sparse(:recorded_on) }
	    [ :left, :right, :middle ].each do |type|
	      specify "#average_#{type}" do
	        expect(sparse.send("average_#{type}", :value)).to be_within(delta).of(5.0)
	      end
	    end
	  end
	end
   
	context 'datetime' do
	  let(:sparse) do
	    resources.sparse(:recorded_at)
	  end
		
	  describe '_left' do    
	    subject { sparse.average_left(:value) }
	    sum = (1 * 0) + (2 * 5) + (0 * 10)
	    it { should be_within(delta).of(sum / 3.0) }
	  end
    
	  describe 'ending' do
	    subject { sparse.ending(DateTime.new(2013, 1, 1, 6)).average_left(:value) }
	    sum = (1 * 0) + (2 * 5) + (1 * 10)
	    it { should be_within(delta).of(sum / 4.0) }
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
  
	  describe 'starting' do
	    subject { sparse.starting(DateTime.new(2013, 1, 1, 1)).average_right(:value) }
	    sum = (1 * 0) + (1 * 5) + (2 * 10)
	    it { should be_within(delta).of(sum / 4.0) }
	  end
	end
  
end