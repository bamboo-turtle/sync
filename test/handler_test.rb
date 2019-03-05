require File.join(Dir.pwd, "test", "test_helper")
require "handler"

class HandlerTest < Minitest::Test
  include ProductHelpers

  def test_sync_products
    sns = Minitest::Mock.new
    sync = Minitest::Mock.new

    Aws::SNS::Client.stub(:new, sns) do
      Synchroniser.stub(:new, sync) do
        sns.expect(:list_topics, Struct.new(:topics).new([
          Struct.new(:topic_arn).new("arn:123:#{SIMPLE_PRODUCT_TOPIC}"),
          Struct.new(:topic_arn).new("arn:456:#{VARIABLE_PRODUCT_TOPIC}"),
        ]))

        variable_product = self.variable_product
        simple_product = self.simple_product

        sync.expect(:variable_products_for_sync, [variable_product])
        sync.expect(:simple_products_for_sync, [simple_product])

        sns.expect(:publish, nil, [{
          topic_arn: "arn:456:#{VARIABLE_PRODUCT_TOPIC}",
          message: { "ids" => variable_product.airtable_ids }.to_json
        }])
        sns.expect(:publish, nil, [{
          topic_arn: "arn:123:#{SIMPLE_PRODUCT_TOPIC}",
          message: { "id" => simple_product.airtable_id }.to_json
        }])

        sync_products(event: nil, context: nil)
      end
    end

    sns.verify
    sync.verify
  end

  def test_sync_simple_product
    event = { "Records" => [ { "Sns" => { "Message" => { "id" => "id-1" }.to_json } } ] }
    sync = Minitest::Mock.new
    Synchroniser.stub(:new, sync) do
      sync.expect(:sync_simple_product, nil, ["id-1"])
      sync_simple_product(event: event, context: nil)
    end
  end

  def test_sync_variable_product
    event = { "Records" => [ { "Sns" => { "Message" => { "ids" => %w(id-1 id-2) }.to_json } } ] }
    sync = Minitest::Mock.new
    Synchroniser.stub(:new, sync) do
      sync.expect(:sync_variable_product, nil, [%w(id-1 id-2)])
      sync_variable_product(event: event, context: nil)
    end
  end
end
