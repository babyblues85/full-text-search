module Searchable
  extend ActiveSupport::Concern

  included do
    class_attribute :searchable_columns_value
    has_many :search_documents, as: :searchable
    after_save :update_stems
  end

  def update_stems
    if self.searchable_columns_value.nil? || self.searchable_columns_value.empty?
      raise "Define searchable columns using #searchable_columns class method"
    end

    SearchDocument.transaction do
      document = SearchDocument.find_or_initialize_by(searchable_type: self.class.name, searchable_id: self.id)

      words = self.attributes.symbolize_keys
              .values_at(*Array(self.searchable_columns_value))
              .flat_map { |value| DefaultWordBreaker.new(value).split }
              .uniq
              .map { |word| DefaultStemmer.stem(word) }

      document.stems = words
      document.save
    end
  end

  module ClassMethods
    def searchable_columns(*columns)
      self.searchable_columns_value = columns
    end

    def search(query, options = {})
      prepared_words = prepare_words(query)
      inclusions = prepared_words[:included]
      exclusions = prepared_words[:excluded]

      where("id IN (#{stems_query(inclusions, exclusions)})")
    end

    def prepare_words(query)
      words = query.split(/ +/)
      results = {
        excluded: [],
        included: []
      }

      words.each do |word|
        if word.first == "-"
          results[:excluded] << DefaultStemmer.stem(word[1..-1])
        else
          results[:included] << DefaultStemmer.stem(word)
        end
      end

      results
    end

    def stems_query(inclusions, exclusions)
      relation = SearchDocument.select(:searchable_id)
          .where(searchable_type: 'Thing')
          .where("stems @> ARRAY[?]::varchar[]", inclusions)

      if exclusions.any?
        relation = relation.where.not("stems && ARRAY[?]::varchar[]", exclusions)
      end

      relation.to_sql
    end
  end
end