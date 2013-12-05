describe SparseCollection::Find do
  after { Resource.delete_all }
  
  let(:resources) do
    Resource.create([
      { recorded_on: Date.parse('Jan 2, 2013'), value: 1 },
      { recorded_on: Date.parse('Jan 6, 2013'), value: 2 }
    ])
    Resource.all
  end
  
  let(:sparse) { resources.sparse(:recorded_on) }
  let(:date) { nil }

  describe '#find_left' do
    subject { sparse.find_left(date) }

    describe 'defaults to most recent' do
      its(:value) { should eq(2) }
    end

    describe 'too early' do
      let(:date) { Date.parse('Jan 1, 2013') }
      it { should be_nil }
    end

    describe 'exact match' do
      let(:date) { Date.parse('Jan 2, 2013') }
      its(:value) { should eq(1) }
    end

    describe 'in between' do
      let(:date) { Date.parse('Jan 4, 2013') }
      its(:value) { should eq(1) }
    end
  end
  
  describe '#find_middle' do
    subject { sparse.find_middle(date) }

    describe 'early' do
      let(:date) { Date.parse('Jan 1, 2013') }
      its(:value) { should eq(1) }
    end

    describe 'late' do
      let(:date) { Date.parse('Jan 7, 2013') }
      its(:value) { should eq(2) }
    end

    describe 'tie goes to later' do
      let(:date) { Date.parse('Jan 4, 2013') }
      its(:value) { should eq(2) }
    end
  end

  describe '#find_right' do
    subject { sparse.find_right(date) }

    describe 'too late' do
      let(:date) { Date.parse('Jan 7, 2013') }
      it { should be_nil }
    end

    describe 'exact match' do
      let(:date) { Date.parse('Jan 6, 2013') }
      its(:value) { should eq(2) }
    end

    describe 'in between' do
      let(:date) { Date.parse('Jan 4, 2013') }
      its(:value) { should eq(2) }
    end
  end
end