describe SparseCollection::Base do
  describe '::new' do
    specify 'records required' do
      expect do
        SparseCollection::Base.new(nil, :created_at)
      end.to raise_error(ArgumentError)
    end
    
    specify 'field required' do
      expect do
        SparseCollection::Base.new({}, nil)
      end.to raise_error(ArgumentError)
    end
  end
  
  let(:base) { SparseCollection::Base.new(Resource.all, :recorded_on) }
  subject { base }
  
  describe '#beginning' do
    before { base.beginning(Date.today) }
    it { should be_a(SparseCollection::Base) }
    its(:period_begin) { should eq(Date.today) }
  end
  
  describe '#ending' do
    before { base.ending(Date.today) }
    it { should be_a(SparseCollection::Base) }
    its(:period_end) { should eq(Date.today) }
  end
  
  describe '#for' do
    before { base.for(Date.today..Date.tomorrow) }
    it { should be_a(SparseCollection::Base) }
    its(:period_begin) { should eq(Date.today) }
    its(:period_end) { should eq(Date.tomorrow) }
  end
  
  describe '#period' do
    let(:range) { Date.today .. Date.tomorrow }
    before { base.for(range) }
    its(:period) { should eq(range) }
  end
  
  context 'unset' do
    before do
      Resource.create([ { recorded_on: Date.today }, { recorded_on: Date.tomorrow } ])
    end
    
    after { Resource.delete_all }
    
    describe '#period_begin' do
      its(:period_begin) { should eq(Date.today) }
    end
    
    describe '#period_end' do
      its(:period_end) { should eq(Date.tomorrow) }
    end
  end
  
  describe '#seconds_between' do    
    describe 'dates' do
      subject { base.send :seconds_between, Date.yesterday, Date.today }
      it { should be_within(delta).of(24 * 60 * 60) }
    end
    
    describe 'datetimes'
    
    describe 'times'
  end
  
  describe '#attributes_redundant?' do
    
  end
end