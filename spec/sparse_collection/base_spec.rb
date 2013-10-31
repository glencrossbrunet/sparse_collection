require 'spec_helper'

describe Resource do
  let(:collection) { Resource.all.sparse }
  
  describe '#sparse' do
    subject { collection }
    it { should be_a(SparseCollection::Collection) }
  end
  
  let(:date) { Date.today }
  
  describe '#starting | #beginning' do
    subject { collection.beginning(date) }
    
    it { should be_a(SparseCollection::Collection) }
    
    it 'should save the begin value' do
      expect(subject.period_start).to eq(date)
    end
  end
  
  describe '#ending' do
    subject { collection.ending(date) }
    
    it { should be_a(SparseCollection::Collection) }
    
    it 'should save the ending value' do
      expect(subject.period_end).to eq(date)
    end
  end
end