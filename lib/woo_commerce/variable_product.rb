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
      {
        product: product_params.merge(
          attributes: [
            {
              name: "Option",
              position: 0,
              visible: true,
              variation: true,
              options: @product.variants,
            }
          ],
          variations: @product.variations.map { |variation|
            {
              regular_price: variation.display_price,
              image: { src: variation.images[0], position: 0 },
              attributes: [
                {
                  option: variation.variant,
                  name: "Option",
                }
              ]
            }
          }
        )
      }
    end
  end
end