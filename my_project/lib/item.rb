require 'faker'
require 'json'

module MyProject
  class Item
    include Comparable

    attr_accessor :name, :price, :description, :category, :image_path

    def initialize(params = {})
      @name = params[:name] || "Default Name"
      @price = params[:price] || 0
      @description = params[:description] || "No description"
      @category = params[:category] || "Uncategorized"
      @image_path = params[:image_path] || "media/default.jpg"

      yield(self) if block_given?

      if defined?(LoggerManager) && LoggerManager.respond_to?(:logger) && LoggerManager.logger
        LoggerManager.logger.info("Item initialized: #{@name}")
      end
    end

    def update
      yield(self) if block_given?
    end

    def to_s
      "Item: #{@name} | Price: #{@price} | Cat: #{@category}"
    end

    alias_method :info, :to_s

    def to_h
      instance_variables.each_with_object({}) do |var, hash|
        key = var.to_s.delete("@")
        hash[key] = instance_variable_get(var)
      end
    end

    def inspect
      "#<Item:0x#{object_id.to_s(16)} #{to_h}>"
    end

    def <=>(other)
      return nil unless other.is_a?(Item)
      @price <=> other.price
    end

    def self.generate_fake
      new(
        name: Faker::Commerce.product_name,
        price: Faker::Commerce.price(range: 10..1000.0),
        description: Faker::Lorem.sentence,
        category: Faker::Commerce.department,
        image_path: "media/#{Faker::File.file_name(dir: 'path/to', ext: 'jpg')}"
      )
    end
  end
end