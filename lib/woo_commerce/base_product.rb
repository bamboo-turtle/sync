module WooCommerce
  module BaseProduct
    def product_params
      {
        title: @product.name,
        short_description: @product.short_description,
        description: description,
        enable_html_description: true,
        categories: categories,
        images: images,
      }
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
