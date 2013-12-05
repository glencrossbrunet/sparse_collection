describe SparseCollection::Prune do
  after { Resource.delete_all }
  
  let(:resources) do
    Resource.create [
      { recorded_on: Date.parse('Jan 1, 2013'), value: 4 },
      { recorded_on: Date.parse('Jan 2, 2013'), value: 4 },
      { recorded_on: Date.parse('Jan 3, 2013'), value: 5 },
      { recorded_on: Date.parse('Jan 4, 2013'), value: 7 },
      { recorded_on: Date.parse('Jan 5, 2013'), value: 5 },
      { recorded_on: Date.parse('Jan 6, 2013'), value: 4 },
      { recorded_on: Date.parse('Jan 7, 2013'), value: 3 }
    ]
    Resource.all
  end
  let(:count) { resources.count }
  before { count }
  let(:sparse) { resources.sparse(:recorded_on) }

  describe '#prune_left' do
    context 'exact' do
      let(:pruned) { sparse.prune_left(:value) }
      
      it 'should remove 1' do
        expect(pruned.count).to eq(count - 1)
      end

      it 'should remove dups on right' do
        expect(pruned.find_by recorded_on: Date.parse('Jan 2, 2013')).to be_nil
      end
    end
    
    context 'close' do
      let(:pruned) { sparse.prune_left(value: 1) }

      it 'should remove 3' do
        expect(pruned.count).to eq(count - 3)
      end

      it 'should remove dups on left' do
        expect(pruned.find_by recorded_on: Date.parse('Jan 2, 2013')).to be_nil
        expect(pruned.find_by recorded_on: Date.parse('Jan 3, 2013')).to be_nil
        expect(pruned.find_by recorded_on: Date.parse('Jan 6, 2013')).to be_nil
      end
    end
  end

  describe '#prune_middle' do
    context 'exact' do
      let(:pruned) { sparse.prune_middle(:value) }

      it 'should remove 0' do
        expect(pruned.count).to eq(count)
      end
    end

    context 'close' do
      let(:pruned) { sparse.prune_middle(value: 1) }

      it 'should remove 1' do
        expect(pruned.count).to eq(count - 1)
      end

      it 'should remove dups in middle' do
        expect(pruned.find_by recorded_on: Date.parse('Jan 2, 2013')).to be_nil
      end
    end
  end

  describe '#prune_right' do
    context 'exact' do
      let(:pruned) { sparse.prune_right(:value) }

      it 'should remove 1' do
        expect(pruned.count).to eq(count - 1)
      end

      it 'should remove dups on left' do
        expect(pruned.find_by recorded_on: Date.parse('Jan 1, 2013')).to be_nil
      end
    end

    context 'close' do
      let(:pruned) { sparse.prune_right(value: 1) }

      it 'should remove 3' do
        expect(pruned.count).to eq(count - 3)
      end

      it 'should remove dups on right' do
        expect(pruned.find_by recorded_on: Date.parse('Jan 1, 2013')).to be_nil
        expect(pruned.find_by recorded_on: Date.parse('Jan 2, 2013')).to be_nil
        expect(pruned.find_by recorded_on: Date.parse('Jan 6, 2013')).to be_nil
      end
    end
  end
end