require File.join(Dir.pwd, "test", "test_helper")

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
    assert_nil Product.extract_cup_weight(%Q{<p><a href="https://www.organicup.com/help/">Organicup</a>.</p>})
  end

  def test_images
    product = Product.new("images" => "url1\nurl2\n\nurl3")
    assert_equal %w(url1 url2 url3), product.images
  end
end
