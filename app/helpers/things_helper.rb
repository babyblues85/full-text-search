module ThingsHelper

  def highlighted_content(content, query)
    stems = Thing.prepare_words(query)[:included]
    words = Thing.word_breaker_value.new(content).split

    conversions = Hash[words.map { |word| [Thing.stemmer_value.stem(word), word] }].slice(*stems)
    conversions.values.each do |word|
      content.gsub!(word) { |highlight| content_tag(:span, highlight, class: 'highlight') }
    end
    content
  end
end
