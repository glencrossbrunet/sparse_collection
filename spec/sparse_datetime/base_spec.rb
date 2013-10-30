require 'spec_helper'

describe Resource do
  let(:collection) { Resource.all.sparse }
  
  describe '#sparse' do
    subject { collection }
    it { should be_a(SparseDatetime::Collection) }
  end
  
  describe '#starting | #beginning' do
    date = Date.today
    before { collection.beginning(date) }
    it 'should save the begin value' do
      expect(collection.period_start).to eq(date)
    end
  end
  
  describe '#ending' do
    date = Date.today
    before { collection.ending(date) }
    it 'should save the ending value' do
      expect(collection.period_end).to eq(date)
    end
  end
end