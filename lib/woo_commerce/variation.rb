module WooCommerce
  class Variation
    def initialize(product)
      @product = product
    end

    def params
      {
        id: @product.woocommerce_id,
        regular_price: @product.price,
        attributes: [
          {
            option: @product.variant,
            name: "Option",
          }
        ]
      }.merge(image_params)
    end

    def image_params
      if @product.images_out_of_sync?
        { image: image }
      else
        {}
      end
    end

    private

    def image
      if @product.images[0]
        [{ src: @product.images[0], position: 0 }]
      else
        ""
      end
    end
  end
end
