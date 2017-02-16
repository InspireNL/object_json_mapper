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
end
