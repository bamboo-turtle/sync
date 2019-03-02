require "uri"
require "net/http"
require "json"

class AirtableStore
  BASE_URL = "https://api.airtable.com/v0/"
  DATABASE_ID = "appUXiZEB77F0sbcQ"
  API_KEY = "key27JmO7MIe5Q9Nn"

  module Tables
    PRODUCTS = "Products"
    CATEGORIES = "Categories"
  end

  def self.categories
    new(Tables::CATEGORIES).read.map { |record|
      fields = record.fetch("fields").slice(*::Category::HEADERS)

      ::Category.new(
        fields
          .merge("airtable_id" => record.fetch("id"))
          .merge("image" => fields["image"] && fields["image"][0].fetch("url"))
      )
    } 
  end

  def self.products
    categories = self.categories.map { |c| [c.airtable_id, c] }.to_h

    new(Tables::PRODUCTS).read.map { |record|
      fields = record.fetch("fields")

      ::Product.new(
        fields
          .merge("airtable_id" => record.fetch("id"))
          .merge("images" => Array(fields["images"]).map { |image| image.fetch("url") })
          .merge("category" => categories.fetch(fields.fetch("category")[0]))
      )
    }
  end

  def self.product(id)
    categories = self.categories.map { |c| [c.airtable_id, c] }.to_h

    record = new(Tables::PRODUCTS).read_one(id)
    fields = record.fetch("fields")

    ::Product.new(
      fields
        .merge("airtable_id" => record.fetch("id"))
        .merge("images" => Array(fields["images"]).map { |image| image.fetch("url") })
        .merge("category" => categories.fetch(fields.fetch("category")[0]))
    )
  end

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

  def initialize(table_name)
    @table_name = table_name
  end

  def read
    records = []
    response = {}

    begin
      request = Net::HTTP::Get.new(url.merge("?#{URI.encode_www_form(offset: response["offset"])}"))
      response = perform_request(request)
      records += response.fetch("records")
    end while response["offset"]

    records
  end

  def read_one(id)
    perform_request(Net::HTTP::Get.new(URI("#{url}/#{id}")))
  end

  def write(record, field_names = [])
    request = if record.airtable_id
      Net::HTTP::Patch.new(URI("#{url}/#{record.airtable_id}"))
    else
      Net::HTTP::Post.new(url)
    end

    fields = self.class.const_get(record.class.name).new(record).fields
    if field_names.any?
      fields = fields.slice(*field_names)
    end
    request.body = { "fields" => fields }.to_json

    record.update("airtable_id" => perform_request(request).fetch("id"))
  end

  def url
    @url ||= URI(URI.join(BASE_URL, "#{DATABASE_ID}/", URI.escape(@table_name)))
  end

  private

  def perform_request(request)
    request["Authorization"] = "Bearer #{API_KEY}"
    request["Content-Type"] = "application/json"

    http = Net::HTTP.new(url.hostname, url.port)
    http.use_ssl = true
    http.set_debug_output($stdout)
    JSON.parse(http.start { http.request(request) }.body)
  end
end
