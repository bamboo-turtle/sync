require "lib/product"
require "lib/category"
require "lib/variable_product"
require "lib/synchroniser"
require "aws-sdk-sns"
require "json"

SIMPLE_PRODUCT_TOPIC = "sync-simple-product"
VARIABLE_PRODUCT_TOPIC = "sync-variable-product"

def sync_products(event:, context:)
  airtable = Airtable::Store.new(
    database_id: ENV["AIRTABLE_DATABASE"],
    api_key: ENV["AIRTABLE_API_KEY"]
  )

  sns = Aws::SNS::Client.new
  topics = sns.list_topics.topics.map { |t|
    [
      t.topic_arn.split(":").last,
      t.topic_arn
    ]
  }.to_h

  variable, simple = airtable.products.partition(&:variant)

  VariableProduct.map(variable).select(&:out_of_sync?).each do |product|
    sns.publish(
      topic_arn: topics.fetch(VARIABLE_PRODUCT_TOPIC),
      message: { ids: product.airtable_ids }.to_json,
    )
  end

  simple.select(&:out_of_sync?).each do |product|
    sns.publish(
      topic_arn: topics.fetch(SIMPLE_PRODUCT_TOPIC),
      message: { id: product.airtable_id }.to_json,
    )
  end

  nil
end

def sync_simple_product(event:, context:)
  event["Records"].each do |record|
    id = JSON.parse(record["Sns"]["Message"])["id"]
    Synchroniser.synchronise_simple_product(id)
  end
end

def sync_variable_product(event:, context:)
  event["Records"].each do |record|
    ids = JSON.parse(record["Sns"]["Message"])["ids"]
    Synchroniser.synchronise_variable_product(ids)
  end
end
