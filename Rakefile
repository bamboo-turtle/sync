$:.unshift(Dir.pwd)

require "lib/product"
require "lib/product_repository"
require "lib/woo_commerce"
require "lib/product_processor"
require "lib/airtable_store"
require "lib/utils"

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

desc "Prettify product names"
task :prettify_products do
  products =  ProductRepository.from_csv(File.join("data", "products.csv"))
  puts Product::HEADERS.to_csv

  products.each do |product|
    puts product.update(
      "name" => Product.prettify_name(product.name),
      "variant" => Product.prettify_name(product.variant)
    ).to_csv
  end
end

desc "Clean-up product descriptions"
task :clean_up_descriptions do
  ProductProcessor.perform do |product|
    product.update(
      "short_description" => Utils.clean_up_description(product.short_description),
      "long_description" => Utils.clean_up_description(product.long_description),
    )
  end
end

desc "Populate cup weight from description"
task :populate_cup_weight do
  ProductProcessor.perform do |product|
    product.update(
      "cup_weight" => [
        Product.extract_cup_weight(product.short_description),
        Product.extract_cup_weight(product.long_description)
      ].compact.first
    )
  end
end

desc "Upload to Airtable"
task :upload_to_airtable do
  store = AirtableStore.new("Products")
  ProductProcessor.perform do |product|
    store.store(product)
  end
end
