require File.join(Dir.pwd, "test", "test_helper")
require "lib/airtable/store"

class AirtableStoreTest < Minitest::Test
  include Fixtures

  def setup
    @airtable = Airtable::Store.new(database_id: "database-id", api_key: "api-key")
  end

  def test_retrieve_categories
    stub_categories_request

    categories = @airtable.categories
    assert_equal 19, categories.size

    category = categories.find { |c| c.name == "Bags" }
    assert_equal "rectzHKqBZOc3eJVx", category.airtable_id
    assert_equal "https://dl.airtable.com/.attachments/a39887e2cf475f32d454dc2b83047a64/bb9a5fc1/24862480_1869784196665896_1742877809472711991_n.jpg", category.image
    assert_equal "20", category.woocommerce_id
    assert_equal "BAGS", category.woocommerce_name
    assert_equal ["bags jars bottles boxes"], category.eposnow_names
  end

  def test_retrieve_product
    stub_categories_request

    fixture = json_fixture("airtable_products")
      .fetch("records")
      .find { |product| product.dig("fields", "name") == "Beeswax wrap" }

    stub_request(:get, "#{Airtable::Store::BASE_URL}/database-id/Products/record-id")
      .to_return(body: fixture.to_json)

    product = @airtable.product("record-id")
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

  def test_retrieve_all_products
    stub_categories_request

    stub_request(:get, "#{Airtable::Store::BASE_URL}/database-id/Products?offset")
      .to_return(body: json_fixture("airtable_products").to_json)

    products = @airtable.products
    assert_equal 100, products.size

    product = products.find { |p| p.name == "Beeswax wrap" }
    assert_equal "rec0r31fsA327CW2G", product.airtable_id
  end

  def test_retrieve_products_by_id
    stub_categories_request

    stub_request(:get, "#{Airtable::Store::BASE_URL}/database-id/Products?filterByFormula=OR(RECORD_ID()='id-1',RECORD_ID()='id-2')")
      .to_return(body: {
          records: json_fixture("airtable_products").fetch("records")[0, 2]
        }.to_json)

    products = @airtable.products_by_id(%w(id-1 id-2))
    assert_equal 2, products.size
    assert products[0].airtable_id
    assert products[1].airtable_id
  end

  def stub_categories_request
    stub_request(:get, "#{Airtable::Store::BASE_URL}/database-id/Categories")
      .to_return(body: json_fixture("airtable_categories").to_json)
  end
end
