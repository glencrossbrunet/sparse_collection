describe SparseCollection::Redundance do
  after { Resource.delete_all }
  
  let(:sparse) { Resource.all.sparse(:recorded_on) }
  
  before { Resource.create recorded_on: Date.today, value: 1 }
  
  describe '#redundant_left?' do
    subject { sparse.redundant_left? resource, :value }
    
    describe 'redundant' do
      let(:resource) { Resource.new recorded_on: Date.tomorrow, value: 1 }
      it { should be_true }
    end
    
    describe 'earlier' do
      let(:resource) { Resource.new recorded_on: Date.yesterday, value: 1 }
      it { should be_false }
    end
    
    describe 'different value' do
      let(:resource) { Resource.new recorded_on: Date.tomorrow, value: 2 }
      it { should be_false }
    end
  end
  
  describe '#redundant_right?' do
    subject { sparse.redundant_right? resource, :value }
    
    describe 'redundant' do
      let(:resource) { Resource.new recorded_on: Date.tomorrow, value: 1 }
      it { should be_false }
    end
    
    describe 'earlier' do
      let(:resource) { Resource.new recorded_on: Date.yesterday, value: 1 }
      it { should be_true }
    end
    
    describe 'different value' do
      let(:resource) { Resource.new recorded_on: Date.yesterday, value: 2 }
      it { should be_false }
    end
  end
  
end