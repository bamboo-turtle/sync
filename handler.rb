require "aws-sdk-sns"
require "json"
require "sync"

SIMPLE_PRODUCT_TOPIC = "sync-simple-product"
VARIABLE_PRODUCT_TOPIC = "sync-variable-product"

def sync_products(event:, context:)
  sns = Aws::SNS::Client.new
  topics = sns.list_topics.topics.map { |t|
    [
      t.topic_arn.split(":").last,
      t.topic_arn
    ]
  }.to_h

  sync = Synchroniser.new

  sync.variable_products_for_sync.each do |product|
    sns.publish(
      topic_arn: topics.fetch(VARIABLE_PRODUCT_TOPIC),
      message: { ids: product.airtable_ids }.to_json,
    )
  end

  sync.simple_products_for_sync.each do |product|
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
    Synchroniser.new.sync_simple_product(id)
  end
end

def sync_variable_product(event:, context:)
  event["Records"].each do |record|
    ids = JSON.parse(record["Sns"]["Message"])["ids"]
    Synchroniser.new.sync_variable_product(ids)
  end
end
