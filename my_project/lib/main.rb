require_relative 'app_config_loader'

configurator = AppConfigLoader.new
configurator.load_libs('lib')
configurator.config('config/default_config.yaml')
settings = configurator.config_data
MyProject::LoggerManager.init_logger(settings)

puts "\n--- Step 3.2 Testing Cart & Container ---\n"

cart = MyProject::Cart.new

puts "Generating 5 fake items..."
cart.generate_test_items(5)

puts "\nTesting method_missing (show_all_items):"
cart.show_all_items

puts "\n--- Enumerable Tests ---"

sorted_by_price = cart.sort_by { |item| item.price }
puts "Cheapest item: #{sorted_by_price.first.price}"
puts "Most expensive: #{sorted_by_price.last.price}"

expensive_items = cart.select { |item| item.price > 500 }
puts "Items > $500 count: #{expensive_items.count}"

names = cart.map { |item| item.name }
puts "Item names: #{names.first(3).join(', ')}..."

puts "\n--- Saving Tests ---"
cart.save_to_file("test_cart.txt")
cart.save_to_json("test_cart.json")
cart.save_to_csv("test_cart.csv")
cart.save_to_yml("test_cart_yaml")

puts "Files saved. Check your project folder."

puts "\nClass Info: #{MyProject::Cart.class_info}"