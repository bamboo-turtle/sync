require "lib/airtable/store"
require "lib/woo_commerce/store"

module Synchroniser
  def self.synchronise_product(id)
    airtable = Airtable::Store.new(
      database_id: ENV["AIRTABLE_DATABASE"],
      api_key: ENV["AIRTABLE_API_KEY"]
    )
    wc = WooCommerce::Store.new(
      url: ENV["WOOCOMMERCE_URL"],
      key: ENV["WOOCOMMERCE_KEY"],
      secret: ENV["WOOCOMMERCE_SECRET"]
    )
    wc.update_product(airtable.product(id))
  end
end
