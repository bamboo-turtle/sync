require File.join(Dir.pwd, "test", "test_helper")
require "lib/synchroniser"

class SynchroniserTest < Minitest::Test
  include ProductHelpers

  def test_synchronise_simple_product
    product = :product
    airtable_id = "airtable-id"

    stub_external_apis do |wc, airtable|
      airtable.expect(:product, product, [airtable_id])
      wc.expect(:update_simple_product, product, [product])
      airtable.expect(:sync_product, product, [product])
      Synchroniser.synchronise_simple_product(airtable_id)
    end
  end

  def test_synchronise_variable_product
    products = [:product1, :product2]
    airtable_ids = %w(id-1 id-2)

    stub_external_apis do |wc, airtable|
      airtable.expect(:products_by_id, products, [airtable_ids])
      wc.expect(:update_variable_product, VariableProduct.new(products)) do |p|
        p.variations == products
      end
      airtable.expect(:sync_product, products[0], [products[0]])
      airtable.expect(:sync_product, products[1], [products[1]])
      Synchroniser.synchronise_variable_product(airtable_ids)
    end
  end

  def test_simple_products_for_sync
    products = [
      variation,
      simple_product,
      synced_product(variation),
      synced_product(simple_product),
    ]
    sync = Synchroniser.new
    stub_external_apis do |wc, airtable|
      airtable.expect(:products, products)
      assert_equal products.values_at(1), sync.simple_products_for_sync
    end
  end

  def test_variable_products_for_sync
    products = [
      variation,
      simple_product,
      synced_product(variation),
      synced_product(simple_product),
    ]
    sync = Synchroniser.new
    stub_external_apis do |wc, airtable|
      airtable.expect(:products, products)
      assert_equal products.values_at(*0, 2), sync.variable_products_for_sync.flat_map(&:variations)
    end

    products = [
      synced_product(variation),
      synced_product(variation),
    ]
    sync = Synchroniser.new
    stub_external_apis do |wc, airtable|
      airtable.expect(:products, products)
      assert_empty sync.variable_products_for_sync
    end
  end

  def stub_external_apis
    wc = Minitest::Mock.new
    airtable = Minitest::Mock.new

    WooCommerce::Store.stub(:new, wc) do
      Airtable::Store.stub(:new, airtable) do
        yield wc, airtable
      end
    end

    wc.verify
    airtable.verify
  end
end
