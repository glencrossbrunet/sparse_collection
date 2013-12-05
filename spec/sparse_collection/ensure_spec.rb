describe SparseCollection::Ensure do
  after { Resource.delete_all }
  
  let(:resource) do
    Resource.create recorded_on: Date.parse('Jan 2, 2013'), value: 1
  end

  let(:sparse) do
    Resource.where(id: resource.id).sparse(:recorded_on)
  end

  describe '#ensure_left' do
    describe 'invalid' do
      let(:record) { Resource.new }
      before { record.stub(:valid?) { false } }
      subject { sparse.ensure_left(record, :value) }
      it { should eq(false) }
    end
    
    describe 'no precedent' do
      let(:recorded_on) { Date.parse('Jan 1, 2013') }
      let(:record) { Resource.new(recorded_on: recorded_on, value: 1) }
      subject { sparse.ensure_left(record, :value) }
      its(:recorded_on) { should eq(recorded_on) }
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
      subject { sparse.ensure_left(record, :value) }
      its(:recorded_on) { should eq(date) }
    end

    describe 'outside delta added' do
      let(:record) { Resource.new recorded_on: date, value: 2 }
      subject { sparse.ensure_left(record, value: 0.5) }
      its(:recorded_on) { should eq(date) }
    end
  end

  describe '#ensure_right' do
    let(:date) { Date.parse('Jan 1, 2013') }
    
    describe 'no precedent' do
      let(:recorded_on) { Date.parse('Jan 3, 2013') }
      let(:record) { Resource.new recorded_on: recorded_on, value: 1 }
      subject { sparse.ensure_right(record, :value) }
      its(:recorded_on) { should eq(recorded_on) }
    end

    describe 'duplicate not added' do
      let(:record) { Resource.new(recorded_on: date, value: 1) }
      subject { sparse.ensure_right record, :value }
      it { should eq(resource) }
    end

    describe 'within delta not added' do
      let(:record) { Resource.new recorded_on: date, value: 1.2 }
      subject { sparse.ensure_right record, value: 0.5 }
      it { should eq(resource) }
    end

    describe 'different value added' do
      let(:record) { Resource.new recorded_on: date, value: 2 }
      subject { sparse.ensure_right(record, :value) }
      its(:recorded_on) { should eq(date) }
    end

    describe 'outside delta added' do
      let(:record) { Resource.new recorded_on: date, value: 2 }
      subject { sparse.ensure_right(record, value: 0.5) }
      its(:recorded_on) { should eq(date) }
    end
  end
end