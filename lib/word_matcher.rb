class WordMatcher
  class Match
    attr_reader :value, :score

    def self.map(data, query_words)
      data.map { |words, value|
        new(words, query_words, value)
      }
    end

    def initialize(words, query_words, value)
      @query_words = query_words.sort
      @words = words.sort
      @value = value
    end

    def score
      (@words & @query_words).size ** 2 / @words.size.to_f
    end

    def full?
      @words == @query_words
    end
  end

  def initialize(data)
    @data = data.transform_keys { |key| words(key) }
  end

  def find_matches(string)
    query = words(string)

    Match
      .map(@data, query)
      .select { |match| match.score > 0.5 }
      .sort_by(&:score)
      .reverse
  end

  private 

  def words(string)
    string
      .gsub(/\W/, " ")
      .gsub(/\s{1,}/, " ")
      .strip
      .split(" ")
      .map(&:downcase)
      .then { |words| words + words.map { |word| word.sub(/s$/, "") } }
      .uniq
  end
end
