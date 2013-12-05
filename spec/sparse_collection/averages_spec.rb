describe SparseCollection::Averages do
  after { Resource.delete_all }
  
  let(:resources) do
    Resource.create([
      { recorded_on: Date.parse('Jan 2, 2013'), recorded_at: DateTime.new(2013, 1, 1, 2), value: 0 },
      # 1 day / hour gap
      { recorded_on: Date.parse('Jan 3, 2013'), recorded_at: DateTime.new(2013, 1, 1, 3), value: 5 },
      # 2 day / hour gap
      { recorded_on: Date.parse('Jan 5, 2013'), recorded_at: DateTime.new(2013, 1, 1, 5), value: 10 }
    ])
    Resource.all
  end

  context 'date' do
    let(:sparse) { resources.sparse(:recorded_on) }

    describe '#average_left' do
      subject { sparse.average_left(:value) }
      sum = (1 * 0) + (2 * 5) + (0 * 10)
      it { should be_within(delta).of(sum / 3.0) }
    end

    describe '#average_middle' do
      subject { sparse.average_middle(:value) }
      sum = (0.5 * 0) + (0.5 * 5) + (1 * 5) + (1 * 10)
      it { should be_within(delta).of(sum / 3.0) }
    end

    describe '#average_right' do
      subject { sparse.average_right(:value) }
      sum = (0 * 0) + (1 * 5) + (2 * 10)
      it { should be_within(delta).of(sum / 3.0) }
    end

    describe '0 range' do
      let(:date) { Date.parse('Jan 3, 2013') }
      before { sparse.for(date..date) }
      [ :left, :right, :middle ].each do |type|
        specify "#average_#{type}" do
          expect(sparse.send("average_#{type}", :value)).to be_within(delta).of(5.0)
        end
      end
    end
  end

  context 'datetime' do
    let(:sparse) { resources.sparse(:recorded_at) }

    describe '#average_left' do
      subject { sparse.average_left(:value) }
      sum = (1 * 0) + (2 * 5) + (0 * 10)
      it { should be_within(delta).of(sum / 3.0) }
    end

    describe '#average_left with ending' do
      subject { sparse.ending(DateTime.new(2013, 1, 1, 6)).average_left(:value) }
      sum = (1 * 0) + (2 * 5) + (1 * 10)
      it { should be_within(delta).of(sum / 4.0) }
    end

    describe '#average_middle' do
      subject { sparse.average_middle(:value) }
      sum = (0.5 * 0) + (0.5 * 5) + (1 * 5) + (1 * 10)
      it { should be_within(delta).of(sum / 3.0) }
    end

    describe '#average_right' do
      subject { sparse.average_right(:value) }
      sum = (0 * 0) + (1 * 5) + (2 * 10)
      it { should be_within(delta).of(sum / 3.0) }
    end

    describe '#average_right with beginning' do
      subject { sparse.beginning(DateTime.new(2013, 1, 1, 1)).average_right(:value) }
      sum = (1 * 0) + (1 * 5) + (2 * 10)
      it { should be_within(delta).of(sum / 4.0) }
    end
  end
  
  context 'multiple attributes' do
    let(:sparse) { resources.sparse(:recorded_on) }
    
    specify '#averages_left' do
      avgs = sparse.averages_left(:value, :val)
      expect(avgs[:value]).to eq(avgs[:val])
    end
    
    specify '#averages_middle' do
      avgs = sparse.averages_middle(:value, :val)
      expect(avgs[:value]).to eq(avgs[:value])
    end
    
    specify '#averages_right' do
      avgs = sparse.averages_right(:value, :val)
      expect(avgs[:value]).to eq(avgs[:value])
    end
  end
end