$:.unshift(Dir.pwd)

require "bundler/setup"

require "lib/product"
require "lib/product_repository"
require "lib/category"
require "lib/product_processor"
require "lib/utils"
require "lib/csv_store"

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
