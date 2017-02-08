describe ActiveUMS::Routes do
  describe '#element_path' do
    it 'returns correct url for single record' do
      expect(User.element_path(1)).to eq('http://localhost:3000/users/1')
    end
  end

  describe '#collection_path' do
    it 'returns correct url for resource' do
      expect(User.collection_path).to eq('http://localhost:3000/users')
    end
  end

  describe '#association_path' do
    it 'returns correct url for association to given record' do
      expect(User.association_path(1, :posts)).to eq(
        'http://localhost:3000/users/1/posts'
      )
    end
  end
end
