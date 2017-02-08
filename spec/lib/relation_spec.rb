describe ActiveUMS::Relation do
  let!(:true_user) { User.persist(id: 1) }
  let!(:false_user) { User.persist(id: 2) }
  let!(:relation) { ActiveUMS::Relation.new([true_user, false_user]) }

  describe '#find_by' do
    context 'with existing correct record' do
      it 'returns correct record by conditions' do
        expect(relation.find_by(id: 1)).to eq(true_user)
      end
    end

    context 'without existing correct record' do
      it 'returns nil' do
        expect(relation.find_by(id: 3)).to eq(nil)
      end
    end
  end

  describe '#find' do
    context 'with existing correct record' do
      it 'returns correct record by id' do
        expect(relation.find(1)).to eq(true_user)
      end
    end

    context 'without existing correct record' do
      it 'returns nil' do
        expect(relation.find(3)).to eq(nil)
      end
    end
  end

  describe '#exists?' do
    context 'with existing correct record' do
      it 'returns true' do
        expect(relation.exists?(1)).to be true
      end
    end

    context 'without existing correct record' do
      it 'returns false' do
        expect(relation.exists?(3)).to be false
      end
    end
  end
end
