require_relative 'app_config_loader'

begin
  puts "Initializing Application..."

  loader = AppConfigLoader.new
  loader.load_libs('lib')

  loader.config('config/default_config.yaml')
  global_config = loader.config_data

  configurator = MyProject::Configurator.new

  config_overrides = {
    run_website_parser: 1,
    run_save_to_sqlite: 1,
    run_save_to_csv: 1,
    run_save_to_json: 1,
    run_save_to_yaml: 1
    # run_save_to_mongodb: 0
  }

  configurator.configure(config_overrides)

  puts "Starting Engine..."

  engine = MyProject::Engine.new

  engine.run(configurator.config)

rescue StandardError => e
  puts "\n[FATAL ERROR] The application crashed."
  puts "Details: #{e.message}"
  puts e.backtrace.first(5).join("\n")
end