require "woocommerce_api"
require "lib/woo_commerce/product"
require "lib/woo_commerce/variable_product"
require "lib/woo_commerce/variation"

module WooCommerce
  class Store
    def initialize(api: WooCommerce::API, url:, key:, secret:, debug: false)
      api_params = [url, key, secret]
      if debug
        api_params << { httparty_args: { debug_output: $stdout } }
      end
      @api = api.new(*api_params)
    end

    def update_simple_product(product)
      wc_product = Product.new(product)
      response = @api.put("products/#{wc_product.id}", wc_product.params)
      product.update("woocommerce_id" => response.parsed_response.fetch("product").fetch("id"))
    end

    def update_variable_product(product)
      variable_product = VariableProduct.new(product)
      response = @api.put("products/#{variable_product.id}", variable_product.params).parsed_response.fetch("product")
      ::VariableProduct.new(
        product.variations.zip(response.fetch("variations")).map { |variation, variation_response|
          variation.update(
            "woocommerce_id" => variation_response.fetch("id"),
            "woocommerce_parent_id" => response.fetch("id"),
          )
        }
      )
    end
  end
end
