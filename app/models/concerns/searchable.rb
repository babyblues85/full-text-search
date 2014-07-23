module Searchable
  extend ActiveSupport::Concern

  included do
    class_attribute :searchable_columns_array, :stemmer_klass, 
                    :word_breaker_klass

    has_many :search_documents, as: :searchable, dependent: :delete_all
    after_save :update_stems

    word_breaker DefaultWordBreaker
    stemmer      DefaultStemmer
  end

  def update_stems
    if self.searchable_columns_array.nil? || self.searchable_columns_array.empty?
      raise "Define searchable columns using #searchable_columns class method"
    end

    SearchDocument.transaction do
      document = SearchDocument.find_or_initialize_by(searchable_type: self.class.name, 
                                                      searchable_id: self.id)

      words = searchable_values
              .flat_map { |value| self.class.word_breaker_klass.new(value).split }
              .map { |word| self.class.stemmer_klass.stem(word) }
              .uniq

      document.stems = words
      document.save
    end

  end

  private

  def searchable_values
    self.attributes.symbolize_keys
    .values_at(*Array(self.searchable_columns_array))
  end

  module ClassMethods
    def searchable_columns(*columns)
      self.searchable_columns_array = columns
    end

    def stemmer(klass)
      self.stemmer_klass = klass
    end

    def word_breaker(klass)
      self.word_breaker_klass = klass
    end

    def search(query, options = {})
      stems = prepare_stems(query)

      where("id IN (#{stems_query(stems[:included], stems[:excluded])})")
    end

    def prepare_stems(query)
      words = query.split(/ +/)
      results = {
        excluded: [],
        included: []
      }

      words.each do |word|
        if word.first == "-"
          results[:excluded] << self.stemmer_klass.stem(word[1..-1])
        else
          results[:included] << self.stemmer_klass.stem(word)
        end
      end

      results
    end

    def stems_query(inclusions, exclusions)
      relation = SearchDocument.select(:searchable_id)
          .where(searchable_type: self.name)
          .where("stems @> ARRAY[?]::varchar[]", inclusions)

      if exclusions.any?
        relation = relation.where.not("stems && ARRAY[?]::varchar[]", exclusions)
      end

      relation.to_sql
    end
  end
end