require_relative 'app_config_loader'

configurator = AppConfigLoader.new

configurator.load_libs('lib')

configurator.config('config/default_config.yaml')

puts "\n--- Loaded Configuration ---"
configurator.pretty_print_config_data
puts "----------------------------\n"

settings = configurator.config_data

MyProject::LoggerManager.init_logger(settings)

MyProject::LoggerManager.logger.info("Application started")
MyProject::LoggerManager.log_processed_file("test_file.txt")
MyProject::LoggerManager.log_error("Test error message")

puts "Done! Check the 'logs' directory."