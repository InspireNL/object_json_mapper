require 'kaminari'
require 'object_json_mapper/extensions/kaminari'

describe Kaminari::ObjectJSONMapper do
  describe 'page 1' do
    before do
      stub_request(:get, 'http://localhost:3000/users')
        .with(query: { page: 1, per_page: 25 })
        .to_return(headers: { 'Per-Page' => 25, 'Total' => 75 })
    end

    subject { User.page(1) }

    it { expect(subject).to be_a(ObjectJSONMapper::Relation) }
    it { expect(subject.current_page).to eq(1) }
    it { expect(subject.prev_page).to be nil }
    it { expect(subject.next_page).to eq(2) }
    it { expect(subject.limit_value).to eq(25) }
    it { expect(subject.total_pages).to eq(3) }
    it { expect(subject.first_page?).to be true }
    it { expect(subject.last_page?).to be false }
    it { expect(subject.out_of_range?).to be false }
  end

  describe 'page 2' do
    before do
      stub_request(:get, 'http://localhost:3000/users')
        .with(query: { page: 2, per_page: 25 })
        .to_return(headers: { 'Per-Page' => 25, 'Total' => 75 })
    end

    subject { User.page(2) }

    it { expect(subject).to be_a(ObjectJSONMapper::Relation) }
    it { expect(subject.current_page).to eq(2) }
    it { expect(subject.prev_page).to eq(1) }
    it { expect(subject.next_page).to eq(3) }
    it { expect(subject.limit_value).to eq(25) }
    it { expect(subject.total_pages).to eq(3) }
    it { expect(subject.first_page?).to be false }
    it { expect(subject.last_page?).to be false }
    it { expect(subject.out_of_range?).to be false }
  end

  describe 'page 3' do
    before do
      stub_request(:get, 'http://localhost:3000/users')
        .with(query: { page: 3, per_page: 25 })
        .to_return(headers: { 'Per-Page' => 25, 'Total' => 75 })
    end

    subject { User.page(3) }

    it { expect(subject).to be_a(ObjectJSONMapper::Relation) }
    it { expect(subject.current_page).to eq(3) }
    it { expect(subject.prev_page).to eq(2) }
    it { expect(subject.next_page).to be nil }
    it { expect(subject.limit_value).to eq(25) }
    it { expect(subject.total_pages).to eq(3) }
    it { expect(subject.first_page?).to be false }
    it { expect(subject.last_page?).to be true }
    it { expect(subject.out_of_range?).to be false }
  end
end
