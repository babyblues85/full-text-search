class DummyThing < ActiveRecord::Base
  self.table_name = "things"
  include Searchable

  searchable_columns :content
end

describe Searchable do
  subject { DummyThing }

  describe ".included" do
    it "adds search configuration attributes" do
      expect(subject).to respond_to(:searchable_columns_array)
      expect(subject).to respond_to(:stemmer_klass)
      expect(subject).to respond_to(:word_breaker_klass)
    end

    it "adds has_many association for Stem joins" do
      expect(subject.reflect_on_association(:stem_joins).macro).to eq(:has_many)
    end

    it "sets word breaker and stemmer do defaults" do
      expect(subject.stemmer_klass).to eq(DefaultStemmer)
      expect(subject.word_breaker_klass).to eq(DefaultWordBreaker)
    end

    it "should call after_save :update_stems callback" do
      thing = subject.new(content: 'test')
      expect(thing).to receive(:update_stems)
      thing.save
    end
  end

  context "destroying searchable object" do
    it "removes all associated :stem_joins" do
      thing = subject.create(content: 'test')
      expect(thing.stem_joins.count).to eq(1)
      thing.destroy
      expect(thing.stem_joins.count).to eq(0)
    end
  end

  describe "#update_stems" do
    context "creating new searchable object" do
      it "creates stems for every word" do
        expect(Stem.count).to eq(0)
        thing = subject.create(content: 'test running')
        expect(Stem.count).to eq(2)
      end

      it "sets stems for the created Stem" do
        thing = subject.create(content: 'test running')
        expect(thing.stems.pluck(:word)).to eq(["test", "run"])
      end
    end

    context "updating existing searchable object" do
      it "it recreates index of stems" do
        thing = subject.create(content: 'test running')
        expect(thing.stems.pluck(:word)).to eq(["test", "run"])
        thing.update_attribute(:content, 'test flying')
        expect(thing.stems.pluck(:word)).to eq(["test", "fly"])
      end
    end
  end

  describe ".search" do
    it "searches by normalized stems" do
      thing = subject.create(content: 'running')
      expect(subject.search("running").first).to eq(thing)
    end

    it "returns only results containing all words from query" do
      thing = subject.create(content: 'quick brown fox')
      subject.create(content: 'red fox jumps')
      expect(subject.search("quick fox").count).to eq(1)
      expect(subject.search("quick fox").first).to eq(thing)
    end

    it "allows excluding results using -word" do
      subject.create(content: 'chrome and firefox mozilla')
      subject.create(content: 'google chrome')

      results = subject.search("chrome -firefox -mozilla").pluck(:content)
      expect(results).to eq(["google chrome"])
    end
  end

  describe ".prepare_stems" do
    it "groups words by inclusion or exclusion" do
      expected = {
        excluded: ['fox'],
        included: ['quick', 'brown']
      }
      expect(subject.prepare_stems("quick brown -fox")).to eq(expected)
    end
  end
 
  describe ".stems_query" do
    context "no exclusions given" do
      it "builds a query for inclusions only" do
        expected = ['quick', 'fox'].map do |word|
          Stem.select(:searchable_id)
          .joins(:stem_joins)
          .where("stem_joins.searchable_type = ? AND stems.word = ?", 'DummyThing', word)
          .to_sql
        end.join(" INTERSECT ")

        expect(subject.stems_query(['quick', 'fox'], [])).to eq(expected)
      end
    end

    context "with exclusions given" do
      it "builds a query for inclusions and exclusions" do
        expected = ['quick', 'fox'].map do |word|
          Stem.select(:searchable_id)
          .joins(:stem_joins)
          .where("stem_joins.searchable_type = ? AND stems.word = ?", 'DummyThing', word)
          .to_sql
        end.join(" INTERSECT ")

        expected += " EXCEPT "  
        expected += ["brown", "slow"].map do |word|
          Stem.select(:searchable_id)
          .joins(:stem_joins)
          .where("stem_joins.searchable_type = ? AND stems.word = ?", 'DummyThing', word)
          .to_sql
        end.join(" EXCEPT ")


        expect(subject.stems_query(['quick', 'fox'], ['brown', 'slow'])).to eq(expected)
      end
    end
  end
end