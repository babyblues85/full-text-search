module ThingsHelper

  def highlighted_content(content, query)
    return content if query.nil?
    stems = Thing.prepare_words(query)[:included]
    words = Thing.word_breaker_value.new(content).split

    conversions = Hash[words.map { |word| [Thing.stemmer_value.stem(word), word] }].slice(*stems)
    conversions.values.each do |word|
      content.gsub!(word) do |highlight| 
        content_tag(:span, highlight, class: 'highlight')
      end
    end
    content
  end
end
