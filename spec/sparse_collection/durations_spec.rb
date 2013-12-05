describe SparseCollection::Durations do
  after { Resource.delete_all }
  
  let(:resources) do
    Resource.create([
      { recorded_at: DateTime.parse('Jan 5, 2013 00:00') },
      { recorded_at: DateTime.parse('Jan 5, 2013 00:30') },
      { recorded_at: DateTime.parse('Jan 5, 2013 03:00') }
    ])
    Resource.all
  end
  
  let(:sparse) { resources.sparse(:recorded_at) }
  
  describe '#durations_left' do
    subject { sparse.durations_left }
    
    describe 'default' do
      it do
        should eq({
          resources[0] => 30 * 60,
          resources[1] => 150 * 60,
          resources[2] => 0
        })
      end
    end
    
    describe 'for time range' do
      before { sparse.for(DateTime.parse('Jan 5, 2013 00:15') .. DateTime.parse('Jan 5, 2013 1:45')) }
      it do
        should eq({
          resources[0] => 15 * 60,
          resources[1] => 75 * 60
        })
      end
    end
  end
  
  describe '#durations_middle' do
    subject { sparse.durations_middle }
    
    describe 'default' do
      it do
        should eq({
          resources[0] => 15 * 60,
          resources[1] => 90 * 60,
          resources[2] => 75 * 60
        })
      end
    end
  end
  
  describe '#durations_right' do
    subject { sparse.durations_right }
    
    describe 'default' do
      it do
        should eq({
          resources[0] => 0,
          resources[1] => 30 * 60,
          resources[2] => 150 * 60
        })
      end
    end
  end
  
end