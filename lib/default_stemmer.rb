class DefaultStemmer
  def self.stem(word)
    Stemmer::stem_word(word.downcase)
  end
end