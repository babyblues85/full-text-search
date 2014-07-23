class DummyThing < ActiveRecord::Base
  self.table_name = "things"
  include Searchable
end

describe Searchable do
  subject { DummyThing }

  describe ".included" do
    it "adds search configuration attributes" do
      expect(subject).to respond_to(:searchable_columns_value)
      expect(subject).to respond_to(:stemmer_value)
      expect(subject).to respond_to(:word_breaker_value)
    end

    it "adds has_many association for SearchDocument" do
      expect(subject.reflect_on_association(:search_documents).macro).to eq(:has_many)
    end

    it "sets word breaker and stemmer do defaults" do
      expect(subject.stemmer_value).to eq(DefaultStemmer)
      expect(subject.word_breaker_value).to eq(DefaultWordBreaker)
    end

    it "should call after_save :update_stems callback" do
      thing = subject.new(content: 'test')
      expect(thing).to receive(:update_stems)
      thing.save
    end
  end

end