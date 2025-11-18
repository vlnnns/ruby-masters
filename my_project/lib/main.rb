require_relative 'app_config_loader'

configurator = AppConfigLoader.new
configurator.load_libs('lib')
configurator.config('config/default_config.yaml')
settings = configurator.config_data
MyProject::LoggerManager.init_logger(settings)

puts "\n--- Step 3.1 Testing Item Class ---\n"


item1 = MyProject::Item.new(name: "Laptop", price: 1500, category: "Electronics")
puts "1. Created via Hash: #{item1}"


item2 = MyProject::Item.new do |i|
  i.name = "Mouse"
  i.price = 50
  i.category = "Accessories"
  i.description = "Wireless mouse"
end
puts "2. Created via Block: #{item2}"


item2.update do |i|
  i.price = 45
end
puts "3. Updated Mouse Price: #{item2.price}"


fake_item = MyProject::Item.generate_fake
puts "4. Fake Item generated: #{fake_item.info}"
puts "   Fake Details: #{fake_item.inspect}"


puts "\n--- Comparison Test ---"
if item1 > item2
  puts "#{item1.name} ($#{item1.price}) is more expensive than #{item2.name} ($#{item2.price})"
else
  puts "#{item1.name} is cheaper"
end

puts "\n--- Hash Representation ---"
puts item1.to_h