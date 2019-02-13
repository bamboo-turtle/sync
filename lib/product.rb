class Product
  HEADERS = %w(name variant short_description long_description price images cup_weight eposnow_name eposnow_category woocommerce_id woocommerce_name woocommerce_categories)

  def self.prettify_name(name)
    return if name.nil?

    name
      .gsub(/[-]/, " ")
      .gsub(/\s{1,}/, " ")
      .strip
      .downcase
      .capitalize
  end

  def self.extract_cup_weight(text)
    return if text.nil? || text.strip == ""
    weight = text[/cup\D+(\d+)\s?g/i, 1]
    weight && weight.to_i
  end

  def initialize(data)
    if (data.keys - HEADERS).any?
      raise ArgumentError, "Unexpected keys: #{data.keys - HEADERS}"
    end

    @data = data
  end

  def name
    @data.fetch("name")
  end

  def variant
    @data.fetch("variant")
  end

  def short_description
    @data.fetch("short_description")
  end

  def long_description
    @data.fetch("long_description")
  end

  def price
    if value = @data.fetch("price")
      value.to_f
    end
  end

  def woocommerce_id
    @data.fetch("woocommerce_id")
  end

  def woocommerce_name
    @data.fetch("woocommerce_name")
  end

  def add_woocommerce_data(wc_product)
    update(
      "woocommerce_id" => wc_product.id,
      "woocommerce_name" => wc_product.name,
      "woocommerce_categories" => wc_product.categories.join(", "),
      "images" => wc_product.images.to_a.join("\n"),
      "short_description" => wc_product.short_description,
      "long_description" => wc_product.long_description,
    )
  end

  def update(data)
    self.class.new(@data.merge(data))
  end

  def to_csv
    @data.values_at(*HEADERS).to_csv
  end
end
