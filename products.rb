# Load JSON with products from WooCommerce and map them to canonical products

require "csv"
require "json"

PWD = File.expand_path(File.dirname(__FILE__))

$:.unshift(PWD)

require "lib/product"
require "lib/product_repository"
require "lib/word_matcher"
require "lib/woo_commerce"

products = ProductRepository.new(CSV.open(File.join(PWD, "data", "products.csv"), headers: true))

wc_products = WooCommerce::Product.map(JSON.parse(File.read(File.join(PWD, "data", "wc_products.json")))["products"])
used_products = []

name_matcher = WordMatcher.new(wc_products.map { |product| [product.name, product] }.to_h)

puts Product::HEADERS.to_csv

products.each do |product|
  matches = name_matcher.find_matches(product.name)

  output = if matches.any?
    matches = Array(
      matches.find(&:full?) || matches.select { |m| m.score == matches.first.score }
    )
    used_products += matches.map(&:value)
    product.add_woocommerce_data(WooCommerce::Products.new(matches.map(&:value)))
  else

    product
  end

  puts output.to_csv
end

(wc_products - used_products).each do |product|
  puts Product.new({}).add_woocommerce_data(product).to_csv
end
