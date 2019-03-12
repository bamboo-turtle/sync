module WooCommerce
  module BaseProduct
    module Statuses
      DRAFT = "draft"
      PUBLISH = "publish"
    end

    def product_params
      {
        status: status,
        title: @product.name,
        short_description: @product.short_description,
        description: description,
        enable_html_description: true,
        categories: categories,
        images: images,
        attributes: [
          {
            name: "display_price_quantity",
            visible: false,
            variation: false,
            options: @product.display_price_quantity,
          }
        ]
      }
    end

    def status
      @product.enabled ? Statuses::PUBLISH : Statuses::DRAFT
    end

    def description
      if value = @product.long_description
        "<pre>#{value}</pre>"
      end
    end

    def categories
      Array(@product.category).map(&:woocommerce_id)
    end

    def images
      Array(@product.images).map.with_index { |url, i| { src: url, position: i } }
    end
  end
end
