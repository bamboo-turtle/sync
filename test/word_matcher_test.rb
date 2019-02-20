require "test_helper"
require "word_matcher"

class WordMatcherTest < Minitest::Test
  def setup
    @matcher = WordMatcher.new({
      "bamboo ear buds " => :bamboo_ear_buds,
      "bamboo-straws" => :bamboo_straws,
      "organic bamboo toothbrush children" => :bamboo_toothbrush,
    })
  end

  def test_find_match
    assert_equal %i(bamboo_ear_buds), find_matches("Bamboo Buds")
    assert_equal %i(bamboo_straws), find_matches("Bamboo straws")
    assert_equal %i(bamboo_straws), find_matches("Bamboo straw")
    assert_equal %i(bamboo_toothbrush), find_matches("Toothbrush bamboo")

    assert_empty find_matches("bamboo")
  end

  def find_matches(query)
    @matcher.find_matches(query).map(&:value)
  end
end
