require "minitest/autorun"
require "airtable_store"
require "product"

class AirtableStoreTest < Minitest::Test
  def product_data
    Product::HEADERS.map { |key| [key, nil] }.to_h
  end

  def test_product_fields
    product = AirtableStore::Product.new(Product.new(product_data.merge(
      "images" => "url1\nurl2",
      "airtable_id" => "1"
    )))
    fields = product.fields

    assert_equal [{ "url" => "url1" }, { "url" => "url2" }], fields["images"]
    refute fields.has_key?("airtable_id")
  end

  def test_store_url
    store = AirtableStore.new("Test Products")
    assert_equal "https://api.airtable.com/v0/appUXiZEB77F0sbcQ/Test%20Products", store.url.to_s
  end

  def test_create_product
    store = AirtableStore.new("Test Products")
    product = store.store(Product.new(product_data.merge("name" => "Test product")))

    refute_nil product.airtable_id
  end

  def test_update_product
    store = AirtableStore.new("Test Products")
    product = store.store(Product.new(product_data.merge(
      "name" => "Updated test product",
      "images" => "https://i2.wp.com/bambooturtle.co.uk/wp-content/uploads/2018/05/large-bees-wax.jpg\nhttps://i1.wp.com/bambooturtle.co.uk/wp-content/uploads/2018/05/pouch-bees.jpg",
      "airtable_id" => "recwfPkErkPn8bJG8"
    )))

    refute_nil product.airtable_id
  end
end
