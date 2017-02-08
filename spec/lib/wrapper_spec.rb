describe ActiveUMS::Wrapper do
  describe '.to_relation' do
    let!(:user) { User.persist(id: 1) }

    context 'with array of ActiveUMS::Base objects' do
      subject { ActiveUMS::Wrapper.to_relation([user]) }

      it { is_expected.to be_a(ActiveUMS::Relation) }
      it { is_expected.to match_array([user]) }
    end

    context 'with array of hashes' do
      subject do
        ActiveUMS::Wrapper.to_relation([{ id: 1 }], :user)
      end

      it { is_expected.to be_a(ActiveUMS::Relation) }
      it { is_expected.to match_array([user]) }
    end
  end

  describe '.to_record' do
    subject { ActiveUMS::Wrapper.to_record({ id: 1 }, :user) }

    it { is_expected.to be_a(ActiveUMS::Base) }
    it { is_expected.to be_an_instance_of(User) }
  end
end
