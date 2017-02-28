describe ActiveUMS::Relation do
  context 'method chaining' do
    describe '#where' do
      it 'chains conditions' do
        expect(
          User.where(id: 1).where(name: 'Name').conditions
        ).to eq(id: 1, name: 'Name')
      end

      it 'overrides conditions' do
        expect(
          User.where(id: 1).where(id: 2).conditions
        ).to eq(id: 2)
      end
    end
  end

  context 'custom path' do
    describe '#where' do
      let!(:query) do
        stub_request(:get, 'http://localhost:3000/users/confirmed')
          .with(query: { id: 1 })
          .to_return(body: [{ id: 1 }].to_json)
      end

      it 'changes request path' do
        User.class_eval do
          path :confirmed
        end

        User.confirmed.where(id: 1).inspect

        expect(query).to have_been_requested
      end
    end
  end

  context 'finders' do
    let!(:true_user) { User.persist(id: 1) }
    let!(:false_user) { User.persist(id: 2) }

    before do
      stub_request(:get, 'http://localhost:3000/users')
        .to_return(body: [true_user.attributes, false_user.attributes].to_json)
    end

    describe '#find_by' do
      context 'with existing correct record' do
        it 'returns correct record by conditions' do
          expect(User.all.find_by(id: 1)).to eq(true_user)
        end
      end

      context 'without existing correct record' do
        it 'returns nil' do
          expect(User.all.find_by(id: 3)).to eq(nil)
        end
      end
    end

    describe '#find' do
      context 'with existing correct record' do
        it 'returns correct record by id' do
          expect(User.all.find(1)).to eq(true_user)
        end
      end

      context 'without existing correct record' do
        it 'returns nil' do
          expect(User.all.find(3)).to eq(nil)
        end
      end
    end

    describe '#exists?' do
      context 'with existing correct record' do
        it 'returns true' do
          expect(User.all.exists?(1)).to be true
        end
      end

      context 'without existing correct record' do
        it 'returns false' do
          expect(User.all.exists?(3)).to be false
        end
      end
    end
  end

  describe '#pluck' do
    before do
      stub_request(:get, 'http://localhost:3000/users')
        .to_return(body:
          [
            { id: 1, email: 'first@example.com' },
            { id: 2, email: 'second@example.com' }
          ].to_json
        )
    end

    let(:users) { User.all }

    context 'with single attribute' do
      it 'returns array' do
        expect(users.pluck(:id)).to match_array([1, 2])
      end
    end

    context 'with multiple attributes' do
      it 'returns array of arrays' do
        expect(users.pluck(:id, :email)).to match_array(
          [
            [1, 'first@example.com'],
            [2, 'second@example.com']
          ]
        )
      end
    end
  end

  describe '#none' do
    subject { User.where(id: 1).none }

    it { expect(subject).to be_a(ActiveUMS::NullRelation) }
    it { expect(subject.klass).to eq(User) }
    it { expect(subject.conditions).to eq(id: 1) }
    it { expect(subject).to match_array([]) }
  end
end
