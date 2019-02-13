require "minitest/autorun"
require "product"

class ProductTest < Minitest::Test
  def test_prettify_name
    assert_equal "Fusili white", Product.prettify_name(" FUSILI- WHITE ")
  end
end
