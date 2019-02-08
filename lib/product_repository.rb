class ProductRepository
	def initialize(data)
    @products = data.map { |product| Product.new(product.to_h) }
	end

  def each(&blk)
    @products.each(&blk)
  end
end
