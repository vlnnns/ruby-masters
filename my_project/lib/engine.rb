require 'zip'
require_relative 'app_config_loader'
require_relative 'database_connector'
require_relative 'cart'
require_relative 'simple_website_parser'
require_relative 'archive_sender'
require_relative 'logger_manager' # <--- 1. Добавили этот require

module MyProject
  class Engine
    attr_reader :config

    def initialize
      @config = {}
      @cart = nil
      @db_connector = nil
      @logger = nil
    end

    def run(external_config = {})
      load_config

      if !external_config.empty? && @config['configurator']
        @config['configurator'].merge!(external_config)
      end

      initialize_logging

      @logger.info("Engine started.")

      @cart = MyProject::Cart.new

      @db_connector = MyProject::DatabaseConnector.new(@config)
      @db_connector.connect_to_database

      run_methods(@config['configurator'] || {})

      archive_path = archive_files
      send_archive_background(archive_path, "student@example.com")

    rescue StandardError => e
      puts "Engine Critical Error: #{e.message}"
      @logger&.error("Engine Critical Error: #{e.message}")
    ensure
      @db_connector&.close_connection
      @logger&.info("Engine finished.")
    end

    def load_config
      loader = AppConfigLoader.new
      loader.config('config/default_config.yaml')
      @config = loader.config_data

      @config['configurator'] = {
        run_website_parser: 1,
        run_save_to_csv: 1,
        run_save_to_json: 1,
        run_save_to_yaml: 1,
        run_save_to_sqlite: 1,
        run_save_to_mongodb: 0
      }

      puts "Configuration loaded successfully."
    end

    private

    def initialize_logging
      MyProject::LoggerManager.init_logger(@config)
      @logger = MyProject::LoggerManager.logger
    end

    def run_methods(run_params)
      run_params.each do |key, value|
        next if value.to_i == 0

        method_name = key.to_s

        if respond_to?(method_name, true)
          @logger.info("Executing: #{method_name}")
          send(method_name)
        else
          @logger.warn("Method not found for config key: #{key}")
        end
      end
    end


    def run_website_parser
      puts "Running Website Parser..."
      parser = MyProject::SimpleWebsiteParser.new(@config, @cart)
      parser.start_parse
    end

    def run_save_to_csv
      @cart.save_to_csv("result_data.csv")
    end

    def run_save_to_json
      @cart.save_to_json("result_data.json")
    end

    def run_save_to_yaml
      @cart.save_to_yml("result_yaml_dump")
    end

    def run_save_to_sqlite
      return unless @db_connector.db.is_a?(SQLite3::Database)

      puts "Saving to SQLite..."
      @cart.items.each do |item|
        @db_connector.db.execute(
          "INSERT INTO items (name, price, category) VALUES (?, ?, ?)",
          [item.name, item.price, item.category]
        )
      end
      @logger.info("Saved #{@cart.items.size} items to SQLite.")
    end

    def run_save_to_mongodb
      return unless @db_connector.db.is_a?(Mongo::Client)
      collection = @db_connector.db[:items]
      docs = @cart.items.map(&:to_h)
      collection.insert_many(docs) if docs.any?
      @logger.info("Saved to MongoDB.")
    end


    def archive_files
      zip_filename = "data_archive.zip"
      files_to_zip = ["result_data.csv", "result_data.json", "logs/app.log"]

      File.delete(zip_filename) if File.exist?(zip_filename)

      Zip::File.open(zip_filename, create: true) do |zipfile|
        files_to_zip.each do |filename|
          if File.exist?(filename)
            zipfile.add(filename, filename)
          else
            puts "Warning: File not found for archiving: #{filename}"
          end
        end
      end

      @logger.info("Files archived to #{zip_filename}")
      puts "Archive created: #{zip_filename}"
      zip_filename
    end

    def send_archive_background(file_path, email)
      begin
        MyProject::ArchiveSender.perform_async(File.absolute_path(file_path), email)
        puts "Background job enqueued: Send email to #{email}"
      rescue StandardError => e
        puts "Sidekiq Error (Is Redis running?): #{e.message}. Skipping email."
      end
    end
  end
end