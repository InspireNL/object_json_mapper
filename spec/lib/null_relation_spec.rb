describe ObjectJSONMapper::NullRelation do
  describe '#conditions' do
    let!(:query) { stub_request(:get, 'http://localhost:3000/users') }

    it 'returns empty collection' do
      expect(User.none).to match_array([])
    end

    it 'does not make request' do
      User.none
      expect(query).not_to have_been_requested
    end
  end
end
