require File.join(Dir.pwd, "test", "test_helper")
require "lib/synchroniser"

class SynchroniserTest < Minitest::Test
  def test_synchronise_product
    wc_store = Minitest::Mock.new
    airtable = Minitest::Mock.new
    product = :product
    airtable_id = "airtable-id"

    WooCommerce::Store.stub(:new, wc_store) do
      Airtable::Store.stub(:new, airtable) do
        airtable.expect(:product, product, [airtable_id])
        wc_store.expect(:store_products, [:updated_product], [[product]])
        Synchroniser.synchronise_product(airtable_id)
      end
    end

    airtable.verify
    wc_store.verify
  end
end
