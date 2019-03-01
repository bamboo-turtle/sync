require "lib/airtable_store"
require "lib/woo_commerce"

module Syncroniser
  def self.syncronise_product(id)
    wc_store = WooCommerce::Store.new(api_params: [
      ENV["WC_URL"],
      ENV["WC_KEY"],
      ENV["WC_SECRET"],
      { httparty_args: { debug_output: $stdout } }
    ])
    airtable = AirtableStore.new(AirtableStore::Tables::PRODUCTS)
    airtable.write(wc_store.store_products([AirtableStore.product(id)]))
  end
end
