class Product
  ATTRS = %w(name variant short_description long_description price images cup_weight category eposnow_name eposnow_category woocommerce_id woocommerce_name woocommerce_categories airtable_id)

  attr_reader :category

  def initialize(data)
    if (data.keys - ATTRS).any?
      raise ArgumentError, "Unexpected keys: #{data.keys - ATTRS}"
    end

    @data = data
  end

  (ATTRS - %w(price cup_weight woocommerce_id)).each do |attr|
    define_method(attr) { @data[attr] }
  end

  def price
    if value = @data["price"]
      value.to_f
    end
  end

  def cup_weight
    if value = @data["cup_weight"]
      value.to_i
    end
  end

  def woocommerce_id
    if value = @data["woocommerce_id"]
      value.to_s
    end
  end

  def update(data)
    self.class.new(@data.merge(data))
  end
end
