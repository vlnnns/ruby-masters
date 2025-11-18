require 'yaml'
require 'erb'
require 'json'

class AppConfigLoader
  attr_reader :config_data

  def initialize
    @config_data = {}
  end

  def config(default_config_path, yaml_dir = nil)
    load_default_config(default_config_path)

    yaml_directory = yaml_dir || @config_data['default']['yaml_dir']

    root = @config_data['default']['root_dir']
    full_yaml_path = File.expand_path(yaml_directory, root)

    load_config(full_yaml_path)

    yield(self) if block_given?
  end

  def pretty_print_config_data
    puts JSON.pretty_generate(@config_data)
  end

  def load_libs(base_dir = 'lib')
    system_libs = ['date', 'json', 'yaml', 'erb', 'logger']
    system_libs.each { |lib| require lib }

    Dir.glob(File.join(base_dir, '*.rb')).each do |file|
      next if file == __FILE__

      next if file.end_with?('main.rb')

      require_relative "../#{file}"
      puts "Connected: #{file}"
    end
  end

  private

  def load_default_config(path)
    if File.exist?(path)
      yaml_content = ERB.new(File.read(path)).result
      @config_data.merge!(YAML.safe_load(yaml_content))
    else
      puts "Default config not found at: #{path}"
    end
  end

  def load_config(dir)
    return unless Dir.exist?(dir)

    Dir.glob("#{dir}/*.yaml").each do |file|
      content = YAML.safe_load(File.read(file))
      @config_data.merge!(content) if content
    end
  end
end