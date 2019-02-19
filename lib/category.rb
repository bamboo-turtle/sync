class Category
  HEADERS = %w(name image parent woocommerce_id woocommerce_name eposnow_name airtable_id)

  def initialize(data)
    if (data.keys - HEADERS).any?
      raise ArgumentError, "Unexpected keys: #{data.keys - HEADERS}"
    end

    @data = data
  end

  def name
    @data.fetch("name")
  end

  def image
    @data.fetch("image")
  end

  def parent
    @data.fetch("parent")
  end

  def eposnow_name
    @data.fetch("eposnow_name")
  end

  def eposnow_names
    eposnow_name.to_s.split(",")
  end

  def woocommerce_id
    @data.fetch("woocommerce_id")
  end

  def woocommerce_name
    @data.fetch("woocommerce_name")
  end

  def airtable_id
    @data.fetch("airtable_id")
  end

  def update(data)
    self.class.new(@data.merge(data))
  end

  def to_csv
    @data.values_at(*HEADERS).to_csv
  end
end
