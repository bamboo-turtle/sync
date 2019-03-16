require "lib/woo_commerce/base_product"

module WooCommerce
  class VariableProduct
    include BaseProduct

    def initialize(product)
      @product = product
    end

    def id
      @product.woocommerce_id
    end

    def params
      product_params = self.product_params

      {
        product: product_params.merge(
          attributes: product_params[:attributes] + [
            {
              name: "Option",
              visible: true,
              variation: true,
              options: @product.variants,
            }
          ],
          variations: variations.map(&:params)  
        )
      }
    end

    def variations
      @product.variations.map { |variation| Variation.new(variation) }
    end
  end
end
