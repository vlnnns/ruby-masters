require 'json'
require 'csv'
require 'yaml'
require 'fileutils'

require_relative 'item_container'
require_relative 'item'

module MyProject
  class Cart
    include ItemContainer
    include Enumerable

    attr_reader :items

    def initialize
      @items = []
      MyProject::LoggerManager.logger.info("Cart initialized")
    end

    def generate_test_items(count = 5)
      count.times do
        add_item(Item.generate_fake)
      end
    end

    def each(&block)
      @items.each(&block)
    end


    def save_to_file(filename = "cart_items.txt")
      File.open(filename, "w") do |f|
        @items.each { |i| f.puts i.to_s }
      end
      MyProject::LoggerManager.logger.info("Saved to TXT: #{filename}")
    end

    def save_to_json(filename = "cart_items.json")
      File.write(filename, JSON.pretty_generate(@items.map(&:to_h)))
      MyProject::LoggerManager.logger.info("Saved to JSON: #{filename}")
    end

    def save_to_csv(filename = "cart_items.csv")
      CSV.open(filename, "w") do |csv|
        csv << @items.first.to_h.keys if @items.any?
        @items.each do |item|
          csv << item.to_h.values
        end
      end
      MyProject::LoggerManager.logger.info("Saved to CSV: #{filename}")
    end

    def save_to_yml(directory = "cart_yaml_dump")
      FileUtils.mkdir_p(directory)
      @items.each_with_index do |item, index|
        File.write("#{directory}/item_#{index + 1}.yaml", item.to_h.to_yaml)
      end
      MyProject::LoggerManager.logger.info("Saved to YAML in directory: #{directory}")
    end
  end
end