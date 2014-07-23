describe Thing, type: :model do
  it "has :content searchable" do
    expect(Thing.searchable_columns_array).to eq([:content])
  end

  it "uses default English stemmer" do
    expect(Thing.stemmer_klass).to eq(DefaultStemmer)
  end

  it "uses default English word breaker" do
    expect(Thing.word_breaker_klass).to eq(DefaultWordBreaker)
  end
end
