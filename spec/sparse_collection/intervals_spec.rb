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
      let(:sparse) { resources.sparse(:recorded_on) }
      let(:intervals) { sparse.intervals_left(1.day) }
      subject { intervals.map { |i| i.slice(:recorded_on, :value).symbolize_keys } }
      
      describe 'with nils' do
        before { sparse.beginning(Date.parse('Jan 2, 2013')) } 
        before { sparse.ending(Date.parse('Jan 3, 2013')) }
        it do
          should eq([
            { recorded_on: Date.parse('Jan 2, 2013') },
            { recorded_on: Date.parse('Jan 3, 2013'), value: 0 }
          ])
        end        
      end
      
      describe 'normal' do
        it do
          should eq([
            { recorded_on: Date.parse('Jan 3, 2013'), value: 0 },
            { recorded_on: Date.parse('Jan 4, 2013'), value: 0 },
            { recorded_on: Date.parse('Jan 5, 2013'), value: 1 }
          ])
        end
      end
      
      describe 'failing case' do
        before do
          Resource.create([
            { recorded_at: DateTime.parse('Jan 10, 2013 10:00'), value: 0 },
            { recorded_at: DateTime.parse('Jan 11, 2013 02:30'), value: 1 },
            { recorded_at: DateTime.parse('Jan 11, 2013 06:00'), value: 2 }
          ])
        end
        let(:date) { Date.parse('Jan 11, 2013') }
        let(:start) { date.to_datetime.beginning_of_day }
        let(:stop) { date.to_datetime.end_of_day }
        let(:sparse) { resources.sparse(:recorded_at) }
        let(:intervals) { sparse.for(start .. stop).intervals_left(1.hour) }
        subject { intervals.map { |h| h.slice(:value).symbolize_keys } }
      
        it do
          should eq([
            { value: 0 }, { value: 0 }, { value: 0 },
            { value: 1 }, { value: 1 }, { value: 1 },
            { value: 2 }, { value: 2 }, { value: 2 },
            { value: 2 }, { value: 2 }, { value: 2 },
            { value: 2 }, { value: 2 }, { value: 2 },
            { value: 2 }, { value: 2 }, { value: 2 },
            { value: 2 }, { value: 2 }, { value: 2 },
            { value: 2 }, { value: 2 }, { value: 2 }
          ])
        end
      end
    end
  end
  
end