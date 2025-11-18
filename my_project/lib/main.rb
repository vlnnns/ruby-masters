require_relative 'app_config_loader'

configurator_loader = AppConfigLoader.new
configurator_loader.load_libs('lib')
configurator_loader.config('config/default_config.yaml')
MyProject::LoggerManager.init_logger(configurator_loader.config_data)

puts "\n--- Step 3.3 Testing Configurator Class ---\n"

app_config = MyProject::Configurator.new
puts "Default Config: #{app_config.config}"

puts "\nAvailable methods: #{MyProject::Configurator.available_methods}"

puts "\nUpdating configuration..."
app_config.configure(
  run_website_parser: 1,
  run_save_to_csv: 1,
  run_save_to_yaml: 1,
  run_unknown_feature: 1
)

puts "\nUpdated Config: #{app_config.config}"

if app_config.config[:run_website_parser] == 1
  puts "\n[Check] Website Parser is ENABLED"
else
  puts "\n[Check] Website Parser is DISABLED"
end