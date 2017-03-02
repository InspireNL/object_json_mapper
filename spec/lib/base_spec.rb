describe ActiveUMS::Base do
  describe '.find' do
    let!(:query) do
      stub_request(:get, 'http://localhost:3000/users/1')
        .to_return(body: { id: 1 }.to_json)
    end

    it 'returns correct record' do
      expect(User.find(1)).to eq(User.persist(id: 1))
      expect(query).to have_been_requested
    end
  end

  describe '#where' do
    subject { User.where(id: 1) }

    it 'returns relation with records' do
      expect(subject.conditions).to eq(id: 1)
      is_expected.to be_a(ActiveUMS::Relation)
    end
  end

  describe '.create' do
    let!(:query) do
      stub_request(:post, 'http://localhost:3000/users')
        .to_return(body: { id: 1 }.to_json)
    end

    it 'creates record' do
      expect(User.create(id: 1)).to eq(User.persist(id: 1))
      expect(query).to have_been_requested
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

  describe '.scope' do
    before do
      User.class_eval do
        scope :active, -> { where(active: true) }
        scope :confirmed, -> { where(confirmed: true) }
      end
    end

    context 'scope chains' do
      subject { User.active.confirmed }

      it { expect(subject).to be_a(ActiveUMS::Relation) }
      it { expect(subject.conditions).to eq(active: true, confirmed: true) }
    end

    context 'where after scope' do
      subject { User.active.where(id: 1) }

      it { expect(subject).to be_a(ActiveUMS::Relation) }
      it { expect(subject.conditions).to eq(active: true, id: 1) }
    end

    context 'scope after where' do
      subject { User.where(id: 1).active }

      it { expect(subject).to be_a(ActiveUMS::Relation) }
      it { expect(subject.conditions).to eq(id: 1, active: true) }
    end
  end

  describe '#method_missing' do
    let!(:user) { User.persist(id: 1, name: 'Name') }

    context 'if key exists' do
      context 'and defined' do
        it 'returns attribute value by key' do
          expect(user.id).to eq(1)
        end
      end

      context 'and not defined' do
        it 'returns attribute value by key' do
          expect(user.name).to eq('Name')
        end
      end
    end

    context 'if key does not exists' do
      it 'raises exception' do
        expect { user.false_key }.to raise_error(NoMethodError)
      end
    end
  end

  describe '.none' do
    subject { User.none }

    it { expect(subject).to be_a(ActiveUMS::NullRelation) }
    it { expect(subject.klass).to eq(User) }
  end

  describe '.root' do
    before do
      User.class_eval do
        has_many :posts
      end

      class Post < ActiveUMS::Base
      end
    end

    let!(:people) { User.root(:people) }

    it '.all still works' do
      query = stub_request(:get, 'http://localhost:3000/people')
      people.all.collection
      expect(query).to have_been_requested
    end

    it '.find still works' do
      query = stub_request(:get, 'http://localhost:3000/people/1')
      people.find(1)
      expect(query).to have_been_requested
    end

    it '.create still works' do
      query = stub_request(:post, 'http://localhost:3000/people')
      people.create(id: 1)
      expect(query).to have_been_requested
    end

    it '.update still works' do
      query = stub_request(:any, 'http://localhost:3000/people/1')
      people.persist(id: 1).update(id: 2)
      expect(query).to have_been_requested.twice
    end

    it 'associations still works' do
      query = stub_request(:get, 'http://localhost:3000/people/1/posts')
      people.persist(id: 1).posts.collection
      expect(query).to have_been_requested
    end
  end
end
