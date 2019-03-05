require "lib/airtable/store"
require "lib/woo_commerce/store"

class Synchroniser
  def simple_products_for_sync
    products.reject(&:variant).select(&:out_of_sync?)
  end

  def variable_products_for_sync
    VariableProduct.map(products.select(&:variant)).select(&:out_of_sync?)
  end

  def sync_simple_product(id)
    airtable.sync_product(wc.update_simple_product(airtable.product(id)))
  end

  def sync_variable_product(ids)
    wc
      .update_variable_product(VariableProduct.new(airtable.products_by_id(ids)))
      .variations
      .each { |variation| airtable.sync_product(variation) }
  end


  private

  def airtable
    @airtable ||= Airtable::Store.new(
      database_id: ENV["AIRTABLE_DATABASE"],
      api_key: ENV["AIRTABLE_API_KEY"]
    )
  end

  def wc
    @wc ||= WooCommerce::Store.new(
      url: ENV["WOOCOMMERCE_URL"],
      key: ENV["WOOCOMMERCE_KEY"],
      secret: ENV["WOOCOMMERCE_SECRET"]
    )
  end

  def products
    @products ||= airtable.products
  end
end
