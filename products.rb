# Open CSV with products from ePosNow and generate "canonical" products from them

require "csv"

pwd = File.expand_path(File.dirname(__FILE__))

CSV.open(File.join(pwd, "data", "products.csv"), "w") do |output|
  output << %w(name price eposnow_name eposnow_category)

  CSV.foreach(File.join(pwd, "data", "epos_now_products.csv"), headers: true, encoding: "utf-8") do |row|
    output << [
      row["\uFEFFName"],
      row["Sale Price (Inc. Tax)"],
      row["\uFEFFName"],
      row["Category"],
    ]
  end
end
