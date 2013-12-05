describe SparseCollection::Intervals do
  
  after { Resource.delete_all }
  
  let(:resources) do
    Resource.create([
      { recorded_on: Date.parse('Jan 3, 2013'), value: 0 },
      { recorded_on: Date.parse('Jan 5, 2013'), value: 1 }
    ])
    Resource.all
  end
    
  describe '#intervals_left' do
    describe 'dates' do
      let(:intervals) { resources.sparse(:recorded_on).intervals_left(1.day) }
      subject { intervals.map { |i| i.slice(:recorded_on, :value).symbolize_keys } }
      it do
        should eq([
          { recorded_on: Date.parse('Jan 3, 2013'), value: 0 },
          { recorded_on: Date.parse('Jan 4, 2013'), value: 0 },
          { recorded_on: Date.parse('Jan 5, 2013'), value: 1 }
        ])
      end
    end
  end
  
end