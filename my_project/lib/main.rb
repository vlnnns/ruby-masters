require_relative 'app_config_loader'

configurator_loader = AppConfigLoader.new
configurator_loader.load_libs('lib')
configurator_loader.config('config/default_config.yaml')
settings = configurator_loader.config_data
MyProject::LoggerManager.init_logger(settings)

puts "\n--- Step 3.5 Testing DatabaseConnector ---\n"

puts "1. Testing SQLite Connection..."
db_connector = MyProject::DatabaseConnector.new(settings)

db_connector.connect_to_database

if db_connector.db
  puts "[Success] Connected to SQLite object: #{db_connector.db.class}"

  if db_connector.db.is_a?(SQLite3::Database)
    db_connector.db.execute("INSERT INTO items (name, price, category) VALUES (?, ?, ?)", ["Test Item", 99.99, "Test Cat"])
    puts "[Success] Test item inserted into SQLite table."
  end
else
  puts "[Error] Failed to connect to SQLite."
end

db_connector.close_connection

puts "\n2. Testing MongoDB Configuration Switch..."

mongo_settings = settings.dup
mongo_settings['database_config']['database_type'] = 'mongodb'

mongo_connector = MyProject::DatabaseConnector.new(mongo_settings)

begin
  puts "Attempting to connect to MongoDB (may fail if server not running)..."
  mongo_connector.connect_to_database

  if mongo_connector.db
    puts "[Success] Connected to MongoDB!"
    mongo_connector.close_connection
  end
rescue StandardError => e
  puts "MongoDB test skipped/failed (expected if no local server): #{e.message}"
end