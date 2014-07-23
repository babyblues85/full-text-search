describe DefaultWordBreaker do
  describe "#split" do
    it "splits input by punctuation" do
      expect(described_class.new("a,b;c:d?!e").split).to eq(%w{a b c d e})
    end

    it "splits input by whitespace and new lines" do
      expect(described_class.new("a b\t c\nd").split).to eq(%w{a b c d})
    end

    it "splits input by brackets" do
      expect(described_class.new("a(b)[c]").split).to eq(%w{a b c})
    end

    it "splits input by quotes" do
      expect(described_class.new("a \"b\" 'c'").split).to eq(%w{a b c})
    end
  end

  describe "#regexp_splitter" do
    it "builds correct regexp from breakers" do
      expected = Regexp.new("[#{described_class::BREAKERS.join}]+")

      expect(described_class.new(nil).regexp_splitter).to eq(expected)
    end
  end
end