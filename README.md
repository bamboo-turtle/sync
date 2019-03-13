# Sync products between Airtable and WooCommerce

This code syncs products stored in an Airtable with WooCommerce.

## Why Airtable?

The ultimate goal is to sync product data between ePosNow and WooCommerce so
that live stock levels are reflected in WooCommerce. Using Airtable as an
intermediary allows to add things like descriptions and photos to products, map
ePosNow and WooCommerce categories and specify which products should be visible
on the website. Besides it enables bulk editing and can be used a datasource
for other purposes (e.g. other apps or 3rd parties).

## Airtable Schema

### Products

Name | Type | Comment
-----|------|--------
name | string | 
variant | string | Variation name
short_description | text |
long_description | text |
price | decimal | Price per unit, as in ePosNow (e.g. per g)
images | attachments |
cup_weight | integer | Weight of 1 cup of product
display_price_quantity | integer | Quantity of product for the price displayed on the site (e.g. 100g)
category | Category |
enabled | boolean | Display product on the site?
eposnow_name | string |
eposnow_category | string | Used for initial mapping
woocommerce_id | string | ID of the product in WooCommerce
woocommerce_parent_id | string | ID of the parent product in WooCommerce (only applicable to variants)
woocommerce_name | string | Used for initial mapping
woocommerce_categories | string | Used for initial mapping
last_sync_data | text | Snapshot of the data at the most recent synchronisation in JSON

### Categories

Name | Type | Comment
-----|------|--------
name | string |
image | attachment |
parent | string | Name of the parent category
woocommerce_id | string |
woocommerce_name | string | Used for the initial mapping
eposnow_name | string | Used for the initial mapping

## How it works

This code is written in Ruby. It uses Airtable and WooCommerce APIs to get and
update records. It is deployed as AWS Lambda functions (defined in
`handler.rb`) managed using Serverless framework:

* `sync_products`: Executed on a schedule, checks which products require sync and triggers the other two functions
* `sync_simple_product`: Syncs a simple product
* `sync_variable_product`: Syncs a variable product

It stores a snapshot of the data in a separate column on Airtable
(`last_sync_data`) on every sync so that it's possible to tell if a record
requires synchronisation: if the data differs from the snapshot then it has
been updated since the most recent sync and needs to be synchronised again.

## Setup

Run `make setup` and add credentials to the file called `.env`. These are
available as environment variables for the code in all stages.

## Development

Two binstubs are available to help with development:

* `bin/run`: run a command agains a Ruby docker image, e.g. `bin/run bundle`
* `bin/serverless`: run serverless via docker, e.g. `bin/serverless info`

Run all tests with `make test` or indidually with
`bin/run ruby test/path_to_test.rb`

## Deployment

Run `make deploy` to deploy the code to AWS.
