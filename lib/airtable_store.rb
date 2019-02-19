require "uri"
require "net/http"
require "json"

class AirtableStore
  BASE_URL = "https://api.airtable.com/v0/"
  DATABASE_ID = "appUXiZEB77F0sbcQ"
  API_KEY = "key27JmO7MIe5Q9Nn"

  class Product
    def initialize(product)
      @product = product
    end

    def fields
      (@product.class::HEADERS - %w(airtable_id))
        .map { |header| [header, @product.public_send(header)] }
        .to_h
        .then { |fields| fields.merge(
          "images"   => fields["images"].map { |url| { "url" => url } },
          "category" => Array(fields["category"] && fields["category"].airtable_id),
        ) }
    end
  end

  class Category
    def initialize(category)
      @category = category
    end

    def fields
      (@category.class::HEADERS - %w(airtable_id))
        .map { |header| [header, @category.public_send(header)] }
        .to_h
        .then { |fields| fields.merge("image" => Array(fields["image"]).map { |url| { "url" => fields["image"] } }) }
    end
  end

  def initialize(table_name)
    @table_name = table_name
  end

  def write(record, field_names = [])
    request = if record.airtable_id
      Net::HTTP::Patch.new(URI("#{url}/#{record.airtable_id}"))
    else
      Net::HTTP::Post.new(url)
    end

    request["Authorization"] = "Bearer #{API_KEY}"
    request["Content-Type"] = "application/json"

    fields = self.class.const_get(record.class.name).new(record).fields
    if field_names.any?
      fields = fields.slice(*field_names)
    end

    request.body = { "fields" => fields }.to_json

    http = Net::HTTP.new(url.hostname, url.port)
    http.use_ssl = true
    http.set_debug_output($stdout)
    response = http.start { http.request(request) }

    record.update("airtable_id" => JSON.parse(response.body).fetch("id"))
  end

  def url
    @url ||= URI(URI.join(BASE_URL, "#{DATABASE_ID}/", URI.escape(@table_name)))
  end
end
