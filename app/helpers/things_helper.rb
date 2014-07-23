module ThingsHelper
  def highlighted_content(content, query)
    return content if query.nil?
    stems = Thing.prepare_stems(query)[:included]
    words = Thing.word_breaker_klass.new(content).split

    conversions = Hash[words.map { |word| [Thing.stemmer_klass.stem(word), word] }].slice(*stems)
    conversions.values.each do |word|
      content.gsub!(word) do |highlight| 
        content_tag(:span, highlight, class: 'highlight')
      end
    end
    content
  end
end
