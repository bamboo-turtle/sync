require "bundler"
Bundler.setup(:default, :test)

require "minitest/autorun"
require "webmock/minitest"

$:.unshift(Dir.pwd)

require "lib/category"
require "lib/product"
require "lib/variable_product"

module Fixtures
  def json_fixture(name)
    JSON.parse(File.read(File.join("test", "fixtures", "#{name}.json")))
  end
end

module ProductHelpers
  def simple_product(attrs = {})
    Product.new({ "name" => "Test product"}.merge(attrs))
  end

  def variation
    Product.new("name" => "Test", "variant" => "Variant")
  end

  def synced_product(product)
    product.update("last_sync_data" => product.sync_data)
  end
end
