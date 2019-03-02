require File.join(Dir.pwd, "test", "test_helper")
require "lib/synchroniser"

class SynchroniserTest < Minitest::Test
  def test_synchronise_product
    wc = Minitest::Mock.new
    airtable = Minitest::Mock.new
    product = :product
    airtable_id = "airtable-id"

    WooCommerce::Store.stub(:new, wc) do
      Airtable::Store.stub(:new, airtable) do
        airtable.expect(:product, product, [airtable_id])
        wc.expect(:update_product, :updated_product, [product])
        Synchroniser.synchronise_product(airtable_id)
      end
    end

    airtable.verify
    wc.verify
  end
end
