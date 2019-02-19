require "csv"

class CSVStore
  def self.products
    categories = self.categories

    read(Product, "products").map { |product|
      if product.category_name
        product.update({}, categories.find { |category| category.name == product.category_name })
      else
        product
      end
    }
  end

  def self.categories
    read(Category, "categories")
  end

  def self.read(klass, filename)
    CSV.open(File.join("data", "#{filename}.csv"), headers: true, encoding: "utf-8")
      .map { |record| klass.new(record.to_h) }
  end
end
