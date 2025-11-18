require 'logger'
require 'fileutils'

module MyProject
  class LoggerManager
    class << self
      attr_reader :logger

      def init_logger(config)
        log_config = config['logging']

        log_dir = log_config['directory']
        FileUtils.mkdir_p(log_dir) unless Dir.exist?(log_dir)

        log_file = File.join(log_dir, log_config['files']['application_log'])

        @logger = Logger.new(log_file)

        level = log_config['level']
        @logger.level = Logger.const_get(level)

        @logger.info("Logger initialized successfully.")
      end

      def log_processed_file(filename)
        @logger.info("Processed file: #{filename}")
      end

      def log_error(error_message)
        @logger.error("Error: #{error_message}")
      end
    end
  end
end