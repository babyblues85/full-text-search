describe Thing, type: :model do
  it "has :content searchable" do
    expect(Thing.searchable_columns_value).to eq([:content])
  end

  it "uses default English stemmer" do
    expect(Thing.stemmer_value).to eq(DefaultStemmer)
  end

  it "uses default English word breaker" do
    expect(Thing.word_breaker_value).to eq(DefaultWordBreaker)
  end
end
