require "test_helper"
require "product_repository"
require "product"
require "woo_commerce"

class DataValidationTest < Minitest::Test
  DATA_DIR = File.expand_path(File.join(File.dirname(__FILE__), "..", "data"))

  def setup
    @products = ProductRepository.from_csv(File.join(DATA_DIR, "mapped_products.csv"))
    @wc_products = WooCommerce::Product.from_json(File.join(DATA_DIR, "wc_products.json"))
  end

  def test_validate_uniqueness_of_wc_products
    wc_duplicates = @products
      .select(&:woocommerce_id)
      .group_by(&:woocommerce_id)
      .select { |wc_id, values| values.size > 1 }

    message = wc_duplicates
      .map { |id, products|
        "WC product #{products[0].woocommerce_name} " \
        "mapped to multiple products: #{products.map(&:name).join(", ")}" }
      .join("\n")

    assert_empty wc_duplicates, message
  end

  def test_validate_presence_of_wc_products
    used_ids = @products.map(&:woocommerce_id)
    unused_products = @wc_products.select { |product| !used_ids.include?(product.id) }

    message = "Unused WC products: #{unused_products.map(&:name).join(", ")}"
    assert_empty unused_products, message
  end

  def test_validate_prices
    wc_products_by_id = @wc_products.map { |product| [product.id, product] }.to_h

    @products.each do |product|
      if product.price && product.woocommerce_id
        wc_product = wc_products_by_id.fetch(product.woocommerce_id)
        next unless wc_product.price

        if wc_product.price != product.price
          puts "Price mismatch: #{product.name}: #{product.price} vs #{wc_product.price}"
        end
      end
    end
  end
end
