require "lib/woo_commerce/base_product"

module WooCommerce
  class Product
    include BaseProduct

    def initialize(product)
      @product = product
    end

    def id
      @product.woocommerce_id
    end

    def params
      {
        product: product_params.merge(regular_price: @product.price)
      }
    end
  end
end
