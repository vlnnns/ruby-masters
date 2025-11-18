require_relative 'app_config_loader'

configurator_loader = AppConfigLoader.new
configurator_loader.load_libs('lib')
configurator_loader.config('config/default_config.yaml')
settings = configurator_loader.config_data
MyProject::LoggerManager.init_logger(settings)

puts "\n--- Step 3.4 Testing SimpleWebsiteParser ---\n"

app_config = MyProject::Configurator.new
app_config.configure(
  run_website_parser: 1,
  run_save_to_csv: 1,
  run_save_to_json: 1
)

if app_config.config[:run_website_parser] == 1
  puts "Parser initialized..."

  cart = MyProject::Cart.new

  parser = MyProject::SimpleWebsiteParser.new(settings, cart)

  puts "Starting scraping from: #{settings['web_scraping']['start_page']}"
  puts "Please wait..."

  parser.start_parse

  puts "\n--- Parsing Complete ---"
  puts "Total items collected: #{cart.items.size}"

  cart.items.first(3).each { |i| puts i.info }

  if app_config.config[:run_save_to_csv] == 1
    cart.save_to_csv("parsed_data.csv")
    puts "Saved to parsed_data.csv"
  end
else
  puts "Parsing disabled in configuration."
end