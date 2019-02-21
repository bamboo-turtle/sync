class Product
  HEADERS = %w(name variant short_description long_description price images cup_weight category eposnow_name eposnow_category woocommerce_id woocommerce_name woocommerce_categories airtable_id)

  attr_reader :category

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
    @data["name"]
  end

  def variant
    @data["variant"]
  end

  def short_description
    @data["short_description"]
  end

  def long_description
    @data["long_description"]
  end

  def price
    if value = @data["price"]
      value.to_f
    end
  end

  def images
    @data["images"]
  end

  def cup_weight
    if value = @data["cup_weight"]
      value.to_i
    end
  end

  def category
    @data["category"]
  end

  def eposnow_name
    @data["eposnow_name"]
  end

  def eposnow_category
    @data["eposnow_category"]
  end

  def woocommerce_id
    if value = @data["woocommerce_id"]
      value.to_s
    end
  end

  def woocommerce_name
    @data["woocommerce_name"]
  end

  def woocommerce_categories
    @data["woocommerce_categories"]
  end

  def airtable_id
    @data["airtable_id"]
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
