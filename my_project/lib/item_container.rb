module MyProject
  module ItemContainer
    module ClassMethods
      def class_info
        "Class: #{self.name}, Version: 1.0"
      end

      def item_count
        @item_count ||= 0
      end

      def increment_count
        @item_count ||= 0
        @item_count += 1
      end
    end

    module InstanceMethods
      def add_item(item)
        @items << item
        self.class.increment_count
        MyProject::LoggerManager.logger.info("Item added to cart: #{item.name}")
      end

      def remove_item(item)
        @items.delete(item)
        MyProject::LoggerManager.logger.info("Item removed from cart: #{item.name}")
      end

      def delete_items
        @items.clear
        MyProject::LoggerManager.logger.warn("All items deleted from cart")
      end

      def method_missing(method_name, *args, &block)
        if method_name == :show_all_items
          puts "--- All Items in Cart ---"
          @items.each { |item| puts item }
          puts "-------------------------"
        else
          super
        end
      end
    end

    def self.included(base)
      base.extend(ClassMethods)
      base.send(:include, InstanceMethods)
    end
  end
end