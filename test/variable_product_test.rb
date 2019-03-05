require File.join(Dir.pwd, "test", "test_helper")

class VariableProductTest < Minitest::Test
  include ProductHelpers

  def test_mapping
    products = [
      Product.new("airtable_id" => "1", "name" => "Product 1", "variant" => "Variant 1"),
      Product.new("airtable_id" => "2", "name" => "Product 2", "variant" => "Variant 1"),
      Product.new("airtable_id" => "4", "name" => "Product 2", "variant" => "Variant 2"),
      Product.new("airtable_id" => "5", "name" => "Product 1", "variant" => "Variant 2"),
    ]
    result = VariableProduct.map(products)
    assert_equal 2, result.size
    assert_equal %w(1 5), result[0].airtable_ids
    assert_equal %w(2 4), result[1].airtable_ids
  end

  def test_attributes
    product = VariableProduct.new([
      Product.new(
        "name" => "Product",
        "variant" => "Variant 1",
        "category" => Category.new("woocommerce_id" => "category-1"),
        "price" => 9.99,
        "short_description" => "Short description",
        "long_description" => "Long description",
        "images" => ["http://example.com/image1.jpg"],
        "woocommerce_id" => "1:2",
        "airtable_id" => "airtable-id-1",
      ),
      Product.new(
        "name" => "Product",
        "variant" => "Variant 2",
        "category" => Category.new("woocommerce_id" => "category-1"),
        "price" => 19.99,
        "short_description" => "Short description",
        "long_description" => "Long description",
        "images" => ["http://example.com/image2.jpg"],
        "woocommerce_id" => "1:3",
        "airtable_id" => "airtable-id-2",
      )
    ])

    assert_equal "Product", product.name
    assert_equal "Short description", product.short_description
    assert_equal "Long description", product.long_description
    assert_equal "category-1", product.category.woocommerce_id
    assert_equal %w(http://example.com/image1.jpg http://example.com/image2.jpg), product.images
    assert_equal ["Variant 1", "Variant 2"], product.variants
    assert_equal %w(airtable-id-1 airtable-id-2), product.airtable_ids
    assert_equal "1", product.woocommerce_id
  end

  def test_out_of_sync
    product = VariableProduct.new([
      synced_product(simple_product),
      synced_product(simple_product),
    ])
    refute product.out_of_sync?
    product = VariableProduct.new([
      synced_product(simple_product),
      simple_product
    ])
    assert product.out_of_sync?
  end
end
