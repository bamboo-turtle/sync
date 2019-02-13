$:.unshift(Dir.pwd)

require "lib/product"
require "lib/product_repository"
require "lib/woo_commerce"

desc "Add WooCommerce details to canonical products"
task :add_wc_info do
  products =  ProductRepository.from_csv(File.join("data", "products.csv"))
  wc_products = WooCommerce::Product
    .from_json(File.join("data", "wc_products.json"))
    .map { |product| [product.id, product] }
    .to_h

  puts Product::HEADERS.to_csv

  products.each do |product|
    if product.woocommerce_id
      wc_product = wc_products.fetch(product.woocommerce_id)
      product = product.add_woocommerce_data(wc_product)
    end

    puts product.to_csv
  end
end
