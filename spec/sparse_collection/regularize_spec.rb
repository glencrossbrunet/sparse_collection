require 'spec_helper'

describe 'Collection#regularize' do
  
  let(:resources) do
		Resource.delete_all
    resources = [
			{ recorded_at: DateTime.parse('Jan 2, 2013 01:00'), value: 2 },
      { recorded_at: DateTime.parse('Jan 2, 2013 02:00'), value: 4 },
      { recorded_at: DateTime.parse('Jan 2, 2013 06:00'), value: 6 }
    ].each { |attributes| Resource.create attributes }
		Resource.all
  end
  
  let(:sparse) { resources.sparse(:recorded_at) }
  
  describe '_left' do
    
    specify 'two hour period' do
      two_hours = 7200
      expected = [
        { recorded_at: DateTime.parse('Jan 2, 2013 01:00'), value: 2 },
        { recorded_at: DateTime.parse('Jan 2, 2013 03:00'), value: 4 },
        { recorded_at: DateTime.parse('Jan 2, 2013 05:00'), value: 4 },
        { recorded_at: DateTime.parse('Jan 2, 2013 07:00'), value: 6 }
      ]
      sparse.ending DateTime.parse('Jan 2, 2013 07:00')
      expect(sparse.regularize_left two_hours, :value).to eq(expected)
    end
    
    specify 'three hour period' do
      three_hours = 10800
      expected = [
        { recorded_at: DateTime.parse('Jan 2, 2013 00:00'), value: nil },
        { recorded_at: DateTime.parse('Jan 2, 2013 03:00'), value: 3 },
        { recorded_at: DateTime.parse('Jan 2, 2013 06:00'), value: 6 }
      ]
      sparse.starting DateTime.parse('Jan 2, 2013 00:00')
      expect(sparse.regularize_left three_hours, :value).to eq(expected)
    end

  end
  
end