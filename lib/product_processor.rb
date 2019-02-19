require "csv"

class ProductProcessor
  def self.perform(&blk)
    new.perform(&blk)
  end

  def initialize
    @products = CSVStore.products
  end

  def perform(&blk)
    puts Product::HEADERS.to_csv
    @products.each do |product|
      puts blk.call(product).to_csv
    end
  end
end
