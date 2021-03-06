require "net/http"
require "json"

module Airtable
  class Store
    BASE_URL = "https://api.airtable.com/v0"

    module Tables
      PRODUCTS = "Products"
      CATEGORIES = "Categories"
    end

    def initialize(database_id:, api_key:, debug: false)
      @database_id = database_id
      @api_key = api_key
      @debug = debug
    end

    def categories
      @categories ||= begin
        response = perform_request(Net::HTTP::Get.new("#{url}/#{Tables::CATEGORIES}"))
        response.fetch("records").map { |record|
          fields = record.fetch("fields").slice(*Category::ATTRS)

          Category.new(
            fields
              .merge("airtable_id" => record.fetch("id"))
              .merge("image" => fields["image"] && fields["image"][0].fetch("url"))
          )
        }
      end
    end

    def product(id)
      categories = self.categories.map { |c| [c.airtable_id, c] }.to_h
      build_product(categories, perform_request(Net::HTTP::Get.new("#{url}/#{Tables::PRODUCTS}/#{id}")))
    end

    def products
      categories = self.categories.map { |c| [c.airtable_id, c] }.to_h

      records = []
      response = {}

      begin
        response = perform_request(Net::HTTP::Get.new("#{url}/#{Tables::PRODUCTS}?#{URI.encode_www_form(offset: response["offset"])}"))
        records += response.fetch("records")
      end while response["offset"]

      records.map { |record| build_product(categories, record) }
    end

    def products_by_id(ids)
      categories = self.categories.map { |c| [c.airtable_id, c] }.to_h

      formula = "OR(#{ids.map { |id| "RECORD_ID()='#{id}'" }.join(",")})"
      records = perform_request(Net::HTTP::Get.new("#{url}/#{Tables::PRODUCTS}?#{URI.encode_www_form(filterByFormula: formula)}"))
        .fetch("records")

      records.map { |record| build_product(categories, record) }
    end

    def sync_product(product)
      categories = self.categories.map { |c| [c.airtable_id, c] }.to_h
      request = Net::HTTP::Patch.new("#{url}/#{Tables::PRODUCTS}/#{product.airtable_id}")
      request.body = { "fields" => { "last_sync_data" => product.sync_data.to_json } }.to_json
      build_product(categories, perform_request(request))
    end

    private

    def perform_request(request)
      request["Authorization"] = "Bearer #{@api_key}"
      request["Content-Type"] = "application/json"

      http = Net::HTTP.new(url.hostname, url.port)
      http.use_ssl = true
      http.set_debug_output($stdout) if @debug
      JSON.parse(http.start { http.request(request) }.body)
    end

    def url
      @url ||= URI("#{BASE_URL}/#{@database_id}")
    end

    def build_product(categories, record)
      fields = record.fetch("fields")
      Product.new(
        fields
          .merge("airtable_id" => record.fetch("id"))
          .merge("images" => Array(fields["images"]).map { |image| image.fetch("url") })
          .merge("category" => categories.fetch(fields.fetch("category")[0]))
          .merge("last_sync_data" => fields["last_sync_data"] && JSON.parse(fields["last_sync_data"]))
      )
    end
  end
end
