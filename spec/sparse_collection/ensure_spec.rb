require 'spec_helper'

describe 'Collection#ensure' do
  let(:resource) do
    Resource.create recorded_on: Date.parse('Jan 2, 2013'), value: 1
  end
	
  let(:sparse) do
    Resource.where(id: resource.id).sparse(:recorded_on)
  end
	
  describe '_left' do
    specify 'no precedent creates a new record' do
      recorded_on = Date.parse('Jan 1, 2013')
      record = Resource.new recorded_on: recorded_on, value: 1
      expect(sparse.ensure_left(record, :value).recorded_on).to eq(recorded_on)
    end
    
    let(:date) { Date.parse('Jan 3, 2013') }
    
  	describe 'duplicate not added' do
      let(:record) { Resource.new(recorded_on: date, value: 1) }
      subject { sparse.ensure_left record, :value }
      it { should eq(resource) }
  	end
		
  	describe 'within delta not added' do
      let(:record) { Resource.new recorded_on: date, value: 1.2 }
      subject { sparse.ensure_left record, value: 0.5 }
      it { should eq(resource) }
  	end
		
  	describe 'different value added' do
      let(:record) { Resource.new recorded_on: date, value: 2 }
      subject { sparse.ensure_left(record, :value).recorded_on }
      it { should eq(date) }
  	end
		
  	describe 'outside delta added' do
      let(:record) { Resource.new recorded_on: date, value: 2 }
      subject { sparse.ensure_left(record, value: 0.5).recorded_on }
      it { should eq(date) }
  	end
  end
	
  describe '_right' do
  end
end