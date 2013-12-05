describe SparseCollection do
  
  describe '#sparse' do
    subject { Resource.all.sparse }
    
    describe 'field defaults to created_at' do
      its(:field) { should eq(:created_at) }
    end
  end
  
end