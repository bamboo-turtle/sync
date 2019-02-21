require File.join(Dir.pwd, "test", "test_helper")
require "lib/airtable_store"

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
    product = store.write(Product.new(product_data.merge("name" => "Test product")))

    refute_nil product.airtable_id
  end

  def test_update_product
    store = AirtableStore.new("Test Products")
    product = store.write(Product.new(product_data.merge(
      "name" => "Updated test product",
      "images" => "https://i2.wp.com/bambooturtle.co.uk/wp-content/uploads/2018/05/large-bees-wax.jpg\nhttps://i1.wp.com/bambooturtle.co.uk/wp-content/uploads/2018/05/pouch-bees.jpg",
      "airtable_id" => "recgBMig9D9WoMl3x"
    )))

    refute_nil product.airtable_id
  end

  def test_retrieve_categories
    records = JSON.parse(File.read(File.join("test", "fixtures", "airtable_categories.json")))["records"]
    mock_store = Minitest::Mock.new
    mock_store.expect(:read, records)

    AirtableStore.stub(:new, mock_store) do
      categories = AirtableStore.categories
      assert_equal 19, categories.size

      category = categories.find { |c| c.name == "Bags" }
      assert_equal "rectzHKqBZOc3eJVx", category.airtable_id
      assert_equal "https://dl.airtable.com/.attachments/a39887e2cf475f32d454dc2b83047a64/bb9a5fc1/24862480_1869784196665896_1742877809472711991_n.jpg", category.image
      assert_equal "20", category.woocommerce_id
      assert_equal "BAGS", category.woocommerce_name
      assert_equal ["bags jars bottles boxes"], category.eposnow_names
    end
  end

  def test_retrieve_products
    records = JSON.parse(File.read(File.join("test", "fixtures", "airtable_categories.json")))["records"]
    mock_store = Minitest::Mock.new
    mock_store.expect(:read, records)
    categories = AirtableStore.stub(:new, mock_store) { AirtableStore.categories }

    records = JSON.parse(File.read(File.join("test", "fixtures", "airtable_products.json")))["records"]
    mock_store = Minitest::Mock.new
    mock_store.expect(:read, records)

    AirtableStore.stub(:categories, categories) do
      AirtableStore.stub(:new, mock_store) do
        products = AirtableStore.products
        assert_equal 100, products.size

        product = products.find { |p| p.name == "Beeswax wrap" }
        assert_equal "rec0r31fsA327CW2G", product.airtable_id
        assert_equal "General", product.category.name
        assert_equal 8.5, product.price
        assert_match /Please note the patterns/, product.short_description
        assert_match /Available in 4 sizes/, product.long_description
        assert_equal [
          "https://dl.airtable.com/.attachments/4aebf9fa839d32a0fc99d08dde8320db/c4c329dc/large-bees-wax.jpg",
          "https://dl.airtable.com/.attachments/65fc5e1e9264cd934185b92b8e442a29/5bd9fcf1/pouch-bees.jpg",
          "https://dl.airtable.com/.attachments/a0c3da639bda0203c904276a0b0a80e6/700b18f7/med-bees-wax.jpg",
          "https://dl.airtable.com/.attachments/671d0407ddf8a8c96a5c1cda2d09c65f/889e391d/bees-wax-small.jpg"
          ], product.images
        assert_equal "beeswax wrap pouch ", product.eposnow_name
        assert_equal "579:590", product.woocommerce_id
        assert_equal "bees wax wraps sandwich-pouch", product.woocommerce_name
      end
    end
  end
end
