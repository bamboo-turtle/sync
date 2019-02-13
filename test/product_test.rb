require "minitest/autorun"
require "product"

class ProductTest < Minitest::Test
  def test_prettify_name
    assert_equal "Fusili white", Product.prettify_name(" FUSILI- WHITE ")
    assert_nil Product.prettify_name(nil)
  end

  def test_extract_cup_weight
    assert_equal 206, Product.extract_cup_weight("<p>1 cup = 206g</p>")
    assert_equal 196, Product.extract_cup_weight("<p><b><i>1 Cup of oats = 196 g </i></b></p>")
    assert_equal 196, Product.extract_cup_weight("<p><b><i>1 Cup of oats = 196 g </i></b></p>")
    assert_equal 390, Product.extract_cup_weight("<p>1 large cup equals 390 g</p>")
    assert_equal 200, Product.extract_cup_weight("<p>1 cup of chickpeas equals 200 g .</p>\n<p>1 cup of dried chickpeas will make about 3 cups of cooked chickpeas.</p>")
    assert_equal 390, Product.extract_cup_weight("<p>ORGANIC</p>\n<p>1 large cup equals 390 g</p>")
    
    assert_nil Product.extract_cup_weight(nil)
    assert_nil Product.extract_cup_weight("")
    assert_nil Product.extract_cup_weight(%Q{<p>Please refer directly to <a href="https://www.organicup.com/help/" target="_blank" rel="noopener">Organicup</a> website for more information and help.</p>})
  end
end
