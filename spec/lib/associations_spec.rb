describe ObjectJSONMapper::Base do
  before do
    stub_request(:get, 'http://localhost:3000/users/1')
      .to_return(body: { id: 1 }.to_json)

    class Post < ObjectJSONMapper::Base
    end
  end

  let(:user) { User.find(1) }

  describe '.has_many' do
    before do
      User.class_eval do
        has_many :posts
      end
    end

    let!(:query) do
      stub_request(:get, 'http://localhost:3000/users/1/posts')
        .to_return(body: [{ id: 1 }].to_json)
    end

    it 'returns correct record' do
      expect(user.posts).to match_array(Post.persist(id: 1))
      expect(query).to have_been_requested
    end
  end

  describe '.has_one' do
    before do
      User.class_eval do
        has_one :post
      end
    end

    let!(:query) do
      stub_request(:get, 'http://localhost:3000/users/1/post')
        .to_return(body: { id: 1 }.to_json)
    end

    it 'returns correct record' do
      expect(user.post).to eq(Post.persist(id: 1))
      expect(query).to have_been_requested
    end
  end
end
