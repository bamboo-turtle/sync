require "minitest/autorun"
require "bundler/setup"

$:.unshift(Dir.pwd)

require "lib/category"
require "lib/product"

module Fixtures
  def json_fixture(name)
    JSON.parse(File.read(File.join("test", "fixtures", "#{name}.json")))
  end
end

