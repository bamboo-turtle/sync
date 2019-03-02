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
