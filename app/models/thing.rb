class Thing < ActiveRecord::Base
  include Searchable

  searchable_columns :content

  stemmer DefaultStemmer
  word_breaker DefaultWordBreaker
end
