require 'sqlite3'
require 'mongo'
require 'fileutils'

module MyProject
  class DatabaseConnector
    attr_reader :db

    def initialize(config)
      @config = config
      @db = nil
      @db_type = @config['database_config']['database_type']
    end

    def connect_to_database
      MyProject::LoggerManager.logger.info("Attempting to connect to #{@db_type}...")

      case @db_type
      when 'sqlite'
        connect_to_sqlite
      when 'mongodb'
        connect_to_mongodb
      else
        MyProject::LoggerManager.log_error("Unsupported database type: #{@db_type}")
      end
    rescue StandardError => e
      MyProject::LoggerManager.log_error("Database connection failed: #{e.message}")
    end

    def close_connection
      return unless @db

      begin
        if @db.is_a?(SQLite3::Database)
          @db.close
          MyProject::LoggerManager.logger.info("SQLite connection closed.")
        elsif @db.is_a?(Mongo::Client)
          @db.close
          MyProject::LoggerManager.logger.info("MongoDB connection closed.")
        end
        @db = nil
      rescue StandardError => e
        MyProject::LoggerManager.log_error("Error closing connection: #{e.message}")
      end
    end

    private

    def connect_to_sqlite
      db_settings = @config['database_config']['sqlite_database']
      db_file = db_settings['db_file']

      FileUtils.mkdir_p(File.dirname(db_file))

      @db = SQLite3::Database.new(db_file)

      @db.busy_timeout(db_settings['timeout'] || 5000)

      MyProject::LoggerManager.logger.info("Connected to SQLite at #{db_file}")

      create_sqlite_table
    end

    def connect_to_mongodb
      mongo_settings = @config['database_config']['mongodb_database']
      uri = mongo_settings['uri']
      db_name = mongo_settings['db_name']

      Mongo::Logger.logger.level = ::Logger::WARN

      @db = Mongo::Client.new(uri, database: db_name)

      @db.database.command(ping: 1)

      MyProject::LoggerManager.logger.info("Connected to MongoDB: #{db_name}")
    end

    def create_sqlite_table
      @db.execute <<-SQL
        CREATE TABLE IF NOT EXISTS items (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT,
          price REAL,
          category TEXT
        );
      SQL
    end
  end
end