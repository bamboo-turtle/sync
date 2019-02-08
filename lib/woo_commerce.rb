module WooCommerce
  class Product
    def self.map(data)
      data.flat_map { |item|
        product = Product.new(item)

        if product.variable?
          product.variants
        else
          product
        end
      }
    end

    def initialize(data)
      @data = data
    end

    def id
      @data.fetch("id")
    end

    def name
      @data.fetch("title")
    end

    def categories
      @data.fetch("categories")
    end

    def variable?
      @data.fetch("type") == "variable"
    end

    def variants
      @data["variations"].map { |variation|
        ProductVariant.new(self, variation)
      }
    end
  end

  class ProductVariant
    def initialize(product, data)
      @product = product
      @data = data
    end

    def id
      "#{@product.id}:#{@data.fetch("id")}"
    end

    def name
      "#{@product.name} #{variant_name}"
    end

    def categories
      @product.categories
    end

    private

    def variant_name
      @data.fetch("attributes")[0].fetch("option")
    end
  end

  class Products
    def initialize(products)
      @products = products
    end

    def id
      @products.map(&:id).join("|")
    end

    def name
      @products.map(&:name).join("|")
    end
  end
end
