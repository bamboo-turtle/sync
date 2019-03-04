require "woocommerce_api"
require "lib/woo_commerce/product"
require "lib/woo_commerce/variable_product"

module WooCommerce
  class Store
    def initialize(api: WooCommerce::API, url:, key:, secret:, debug: false)
      api_params = [url, key, secret]
      if debug
        params << { httparty_args: { debug_output: $stdout } }
      end
      @api = api.new(*api_params)
    end

    def update_simple_product(product)
      wc_product = Product.new(product)
      response = @api.put("products/#{wc_product.id}", wc_product.params)
      product.update("woocommerce_id" => response.parsed_response.fetch("product").fetch("id"))
    end

    def update_variable_product(product)
      wc_product = VariableProduct.new(product)
      response = @api.put("products/#{wc_product.id}", wc_product.params)
      wc_product = response.parsed_response.fetch("product")
      ::VariableProduct.new(
        product.variations.zip(wc_product.fetch("variations")).map { |variation, wc_variation|
          variation.update("woocommerce_id" => [wc_product.fetch("id"), wc_variation.fetch("id")].join(":"))
        }
      )
    end
  end
end
