describe DefaultStemmer do
  describe ".stem" do
    it "uses fast-stemmer gem" do
      expect(Stemmer).to receive(:stem_word).with("running")
      described_class.stem("running")
    end

    it "converts stems to downcase" do
      expect(described_class.stem("RUNNING")).to eq("run")
    end
  end
end