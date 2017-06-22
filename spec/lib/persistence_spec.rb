describe ObjectJSONMapper::Base do
  describe '.create' do
    context 'without errors' do
      let!(:query) do
        stub_request(:post, 'http://localhost:3000/users')
          .to_return(body: { id: 1 }.to_json)
      end

      it 'creates record' do
        expect(User.create(id: 1)).to eq(User.persist(id: 1))
        expect(query).to have_been_requested
      end
    end

    context 'with errors' do
      let!(:query) do
        stub_request(:post, 'http://localhost:3000/users')
          .to_return(status: 422)
      end

      it 'returns new record' do
        user = User.create

        expect(user).to be_a(User)
        expect(user.persisted?).to be false
        expect(query).to have_been_requested
      end
    end
  end

  describe '#update' do
    before do
      stub_request(:get, 'http://localhost:3000/users/1')
        .to_return(body: { id: 1 }.to_json)
    end

    let!(:query) do
      stub_request(:patch, 'http://localhost:3000/users/1')
        .to_return(body: { id: 1 }.to_json)
    end

    it 'updates record' do
      expect(User.find(1).update(id: 1)).to eq(User.persist(id: 1))
      expect(query).to have_been_requested
    end
  end

  describe '#destroy' do
    before do
      stub_request(:get, 'http://localhost:3000/users/1')
        .to_return(body: { id: 1 }.to_json)
    end

    let!(:query) do
      stub_request(:delete, 'http://localhost:3000/users/1')
    end

    it 'deletes record' do
      expect(User.find(1).destroy).to be true
      expect(query).to have_been_requested
    end
  end
end
