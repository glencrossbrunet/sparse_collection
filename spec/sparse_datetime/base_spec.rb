require 'spec_helper'

describe Resource do
  describe '#sparse' do
    let(:resources) { Resource.all }
    
    describe 'defaults to created_at' do
      subject { resources.sparse.sparse_attribute }
      it { should eq(:created_at) }
    end
    
    describe 'with field' do
      subject { resources.sparse(:recorded_at).sparse_attribute }
      it { should eq(:recorded_at) }
    end
  end
end