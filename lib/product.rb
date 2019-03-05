class Product
  PRODUCT_ATTRS = %w(name variant short_description long_description price images cup_weight display_price_quantity category)
  AUX_ATTRS = %w(eposnow_name eposnow_category woocommerce_id woocommerce_name woocommerce_categories airtable_id last_sync_data)
  ATTRS = PRODUCT_ATTRS + AUX_ATTRS

  attr_reader :category

  def initialize(data = {})
    if (data.keys - ATTRS).any?
      raise ArgumentError, "Unexpected keys: #{data.keys - ATTRS}"
    end

    @data = data
  end

  (ATTRS - %w(price cup_weight display_price_quantity woocommerce_id)).each do |attr|
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

  def display_price_quantity
    if value = @data["display_price_quantity"]
      value.to_i
    else
      1
    end
  end

  def display_price
    price * display_price_quantity
  end

  def woocommerce_id
    if value = @data["woocommerce_id"]
      value.to_s
    end
  end

  def out_of_sync?
    sync_data != last_sync_data
  end

  def sync_data
    @data
      .slice(*PRODUCT_ATTRS)
      .merge("category" => category&.woocommerce_id)
  end

  def last_sync_data
    @data["last_sync_data"]
  end

  def update(data)
    self.class.new(@data.merge(data))
  end
end
