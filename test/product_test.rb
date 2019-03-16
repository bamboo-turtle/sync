require File.join(Dir.pwd, "test", "test_helper")

class ProductTest < Minitest::Test
  include ProductHelpers

  def test_display_price_quantity
    product = Product.new
    assert_equal 1, product.display_price_quantity

    product = Product.new("display_price_quantity" => 100)
    assert_equal 100, product.display_price_quantity
  end

  def test_out_of_sync
    product = Product.new("name" => "Test product")
    assert product.out_of_sync?

    product = product.update("last_sync_data" => product.sync_data)
    refute product.out_of_sync?

    product = product.update("short_description" => "Short desc")
    assert product.out_of_sync?
  end

  def test_images_of_sync
    product = simple_product
    assert product.images_out_of_sync?

    product = synced_product(simple_product)
    refute product.images_out_of_sync?

    product = synced_product(simple_product).update("images" => [])
    assert product.images_out_of_sync?
  end
end
