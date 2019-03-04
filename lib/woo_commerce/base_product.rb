module WooCommerce
  module BaseProduct
    def product_params
      {
        title: @product.name,
        short_description: @product.short_description,
        description: "<pre>#{@product.long_description}</pre>",
        enable_html_description: true,
        categories: [@product.category.woocommerce_id],
        images: @product.images.map.with_index { |url, i| { src: url, position: i } }
      }
    end
  end
end
