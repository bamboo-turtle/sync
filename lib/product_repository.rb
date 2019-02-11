require "csv"

class ProductRepository
  include Enumerable

  def self.from_csv(filename)
    new(CSV.open(filename, headers: true))
  end

	def initialize(data)
    @products = data.map { |product| Product.new(product.to_h) }
	end

  def each(&blk)
    @products.each(&blk)
  end
end
