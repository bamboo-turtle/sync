require "lib/airtable/store"
require "lib/woo_commerce"

module Syncroniser
  def self.syncronise_product(id)
    airtable = Airtable::Store.new(
      database_id: ENV["AIRTABLE_DATABASE"],
      api_key: ENV["AIRTABLE_API_KEY"]
    )
    wc_store = WooCommerce::Store.new(api_params: [
      ENV["WC_URL"],
      ENV["WC_KEY"],
      ENV["WC_SECRET"],
      { httparty_args: { debug_output: $stdout } }
    ])
    wc_store.store_products([airtable.product(id)])
  end
end
