require "json"

module WooCommerce
  require "lib/woo_commerce/store"

  class Product
    def self.from_json(filename)
      map(JSON.parse(File.read(filename))["products"])
    end

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
      @data.fetch("id").to_s
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

    def short_description
      @data.fetch("short_description")
    end

    def long_description
      @data.fetch("description")
    end

    def price
      unless (value = @data.fetch("price")) == ""
        value.to_f
      end
    end

    def images
      Images.new(@data.fetch("images").map { |image| image.fetch("src") })
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

    def short_description
      @product.short_description
    end

    def long_description
      @product.long_description
    end

    def price
      unless (value = @data.fetch("price")) == ""
        value.to_f
      end
    end

    def images
      @product.images + Array(@data.fetch("image")).map { |image| image.fetch("src") }
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

  class Images
    include Enumerable

    def initialize(urls)
      @urls = urls
        .map { |url| sanitize(url) }
        .uniq
    end

    def each(&blk)
      @urls.each(&blk)
    end

    def +(other)
      Images.new(@urls + other.to_a)
    end

    private

    def sanitize(url)
      url.sub(/\?.*$/, "")
    end
  end
end
