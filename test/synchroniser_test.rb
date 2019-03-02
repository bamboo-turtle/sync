require File.join(Dir.pwd, "test", "test_helper")
require "lib/synchroniser"

class SynchroniserTest < Minitest::Test
  def test_synchronise_simple_product
    wc = Minitest::Mock.new
    airtable = Minitest::Mock.new
    product = :product
    airtable_id = "airtable-id"

    WooCommerce::Store.stub(:new, wc) do
      Airtable::Store.stub(:new, airtable) do
        airtable.expect(:product, product, [airtable_id])
        wc.expect(:update_simple_product, nil, [product])
        Synchroniser.synchronise_simple_product(airtable_id)
      end
    end

    airtable.verify
    wc.verify
  end

  def test_synchronise_variable_product
    wc = Minitest::Mock.new
    airtable = Minitest::Mock.new
    products = [:product1, :product2]
    variable_product = :variable_product
    airtable_ids = %w(id-1 id-2)

    WooCommerce::Store.stub(:new, wc) do
      Airtable::Store.stub(:new, airtable) do
        VariableProduct.stub(:new, variable_product) do
          airtable.expect(:products_by_id, products, [airtable_ids])
          wc.expect(:update_variable_product, nil, [variable_product])
          Synchroniser.synchronise_variable_product(airtable_ids)
        end
      end
    end

    airtable.verify
    wc.verify
  end
end
