class Category
  ATTRS = %w(name image parent woocommerce_id woocommerce_name eposnow_name airtable_id)

  def initialize(data = {})
    if (data.keys - ATTRS).any?
      raise ArgumentError, "Unexpected keys: #{data.keys - ATTRS}"
    end

    @data = data
  end

  ATTRS.each do |attr|
    define_method(attr) { @data[attr] }
  end

  def eposnow_names
    eposnow_name.to_s.split(",")
  end

  def update(data)
    self.class.new(@data.merge(data))
  end
end
