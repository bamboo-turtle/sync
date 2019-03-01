require File.join(Dir.pwd, "test", "test_helper")
require "lib/syncroniser"

class SyncroniserTest < Minitest::Test
  def test_syncronise_product
    wc_store = Minitest::Mock.new
    airtable = Minitest::Mock.new
    product = :product
    airtable_id = "airtable-id"

    WooCommerce::Store.stub(:new, wc_store) do
      AirtableStore.stub(:new, airtable) do
        AirtableStore.stub(:product, product) do
          updated_product = :updated_product
          wc_store.expect(:store_products, [updated_product], [[product]])
          airtable.expect(:write, true, [[updated_product]])
          Syncroniser.syncronise_product(airtable_id)
        end
      end
    end

    airtable.verify
    wc_store.verify
  end
end
