describe 'Collection#find' do
	let(:resources) do
		resources = [
			{ recorded_on: Date.parse('Jan 2, 2013'), value: 1 },
			{ recorded_on: Date.parse('Jan 6, 2013'), value: 2 }
		].map(& Resource.method(:create))
		Resource.where(id: resources.map(&:id))
	end
	
	let(:sparse) do
		resources.sparse(:recorded_on)
	end

  describe '_left' do
    subject { sparse.find_left(date).try(:value) }
      
    describe 'defaults to most recent' do
      let(:date) { nil }
      it { should eq(2) }
    end
      
    describe 'no value' do
      let(:date) { Date.parse('Jan 1, 2013') }
      it { should be_nil }
    end
    
    describe 'exact match' do
      let(:date) { Date.parse('Jan 2, 2013') }
      it { should eq(1) }
    end
    
    describe 'in between' do
      let(:date) { Date.parse('Jan 4, 2013') }
      it { should eq(1) }
    end
  end
    
  describe '_right' do
    subject { sparse.find_right(date).try(:value) }
      
    describe 'no value' do
      let(:date) { Date.parse('Jan 7, 2013') }
      it { should be_nil }
    end
      
    describe 'exact match' do
      let(:date) { Date.parse('Jan 6, 2013') }
      it { should eq(2) }
    end
      
    describe 'in between' do
      let(:date) { Date.parse('Jan 4, 2013') }
      it { should eq(2) }
    end
  end
    
  describe '_middle' do
    subject { sparse.find_middle(date).try(:value) }
      
    describe 'early' do
      let(:date) { Date.parse('Jan 1, 2013') }
      it { should eq(1) }
    end
      
    describe 'late' do
      let(:date) { Date.parse('Jan 7, 2013') }
      it { should eq(2) }
    end
      
    describe 'tie goes to later' do
      let(:date) { Date.parse('Jan 4, 2013') }
      it { should eq(2) }
    end
  end
end