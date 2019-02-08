class Product
  HEADERS = %w(name price eposnow_name eposnow_category woocommerce_id woocommerce_name)

  def initialize(data)
    if (data.keys - HEADERS).any?
      raise ArgumentError, "Unexpected keys: #{data.keys - HEADERS}"
    end

    @data = data
  end

  def name
    @data.fetch("name")
  end

  def add_woocommerce_data(wc_product)
    self.class.new(@data.merge(
      "woocommerce_id" => wc_product.id,
      "woocommerce_name" => wc_product.name,
    ))
  end

  def to_csv
    @data.values_at(*HEADERS).to_csv
  end
end
