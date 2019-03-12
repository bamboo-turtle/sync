class VariableProduct
  attr_reader :variations

  def self.map(products)
    products.group_by(&:name).map { |name, group| VariableProduct.new(group) }
  end

  def initialize(variations)
    @variations = variations
  end

  def name
    variations[0].name
  end

  def short_description
    variations[0].short_description
  end

  def long_description
    variations[0].long_description
  end

  def category
    variations[0].category
  end

  def images
    variations.flat_map(&:images).uniq
  end

  def display_price_quantity
    variations[0].display_price_quantity
  end

  def variants
    variations.map(&:variant)
  end

  def airtable_ids
    variations.map(&:airtable_id)
  end

  def woocommerce_id
    variations[0].woocommerce_id.split(":")[0]
  end

  def enabled
    @variations.all?(&:enabled)
  end

  def out_of_sync?
    @variations.any?(&:out_of_sync?)
  end
end
