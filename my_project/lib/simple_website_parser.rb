require 'mechanize'
require 'open-uri'
require 'fileutils'

module MyProject
  class SimpleWebsiteParser
    attr_reader :collection

    def initialize(config, item_collection)
      @config = config
      @collection = item_collection
      @agent = Mechanize.new
      
      @agent.user_agent_alias = 'Mac Safari'
      
      @mutex = Mutex.new
    end

    def start_parse
      url = @config['web_scraping']['start_page']
      MyProject::LoggerManager.logger.info("Start parsing: #{url}")

      return unless check_url_response(url)

      page = @agent.get(url)
      
      product_links = extract_products_links(page)

      puts "Found #{product_links.size} products. Starting threads..."

      threads = []
      
      product_links.each do |link|
        threads << Thread.new do
          begin
            parse_product_page(link)
          rescue StandardError => e
            MyProject::LoggerManager.log_error("Thread error for #{link}: #{e.message}")
          end
        end
      end
      
      threads.each(&:join)

      MyProject::LoggerManager.logger.info("Parsing finished. Total items: #{@collection.items.size}")
    end

    private
    
    def extract_products_links(page)
      selector = @config['web_scraping']['product_name_selector']
      links = page.search(selector).map do |element|
        if element.name == 'a'
          element['href']
        else
          element.parent.name == 'a' ? element.parent['href'] : nil
        end
      end.compact.uniq
      
      links.map { |l| (URI.parse(@config['web_scraping']['start_page']) + l).to_s }
    end

    def parse_product_page(url)
      return unless check_url_response(url)
      
      sleep(rand(0.5..1.5))

      page = @agent.get(url)
      
      name = extract_product_name(page)
      price = extract_product_price(page)
      desc = extract_product_description(page)
      image_url = extract_product_image(page)
      
      category = "General"
      
      local_image_path = save_image(image_url, name, category)
      
      item = Item.new(
        name: name,
        price: price,
        description: desc,
        category: category,
        image_path: local_image_path
      )
      
      @mutex.synchronize do
        @collection.add_item(item)
      end
    end
    

    def extract_product_name(page)
      selector = @config['web_scraping']['product_name_selector']
      element = page.at(selector)
      element ? element.text.strip : "Unknown Product"
    end

    def extract_product_price(page)
      selector = @config['web_scraping']['product_price_selector']
      element = page.at(selector)
      element ? element.text.gsub(/[^\d.]/, '').to_f : 0.0
    end

    def extract_product_description(page)
      selector = @config['web_scraping']['product_description_selector']
      element = page.at(selector)
      element ? element.text.strip : "No description"
    end

    def extract_product_image(page)
      selector = @config['web_scraping']['product_image_selector']
      element = page.at(selector)

      return nil unless element
      
      img_url = element['src'] || element['href']
      
      if img_url && !img_url.start_with?('http')
        URI.join(@config['web_scraping']['start_page'], img_url).to_s
      else
        img_url
      end
    end


    def check_url_response(url)
      uri = URI(url)
      response = Net::HTTP.get_response(uri)
      is_success = response.is_a?(Net::HTTPSuccess)

      unless is_success
        MyProject::LoggerManager.log_error("URL inaccessible: #{url} (Code: #{response.code})")
      end

      is_success
    rescue StandardError => e
      MyProject::LoggerManager.log_error("URL Check Error: #{e.message}")
      false
    end

    def save_image(url, product_name, category)
      return "media/default.jpg" unless url
      
      media_root = @config['default']['media_dir'] || "media"
      safe_name = product_name.downcase.gsub(/[^a-z0-9]+/, '_')
      extension = File.extname(url).split('?').first
      extension = '.jpg' if extension.empty?

      dir_path = File.join(media_root, category.downcase)
      FileUtils.mkdir_p(dir_path) 

      file_path = File.join(dir_path, "#{safe_name}#{extension}")

      begin
        URI.open(url) do |image|
          File.open(file_path, "wb") do |file|
            file.write(image.read)
          end
        end
        MyProject::LoggerManager.logger.info("Image saved: #{file_path}")
        file_path
      rescue StandardError => e
        MyProject::LoggerManager.log_error("Failed to download image: #{url} - #{e.message}")
        "media/default.jpg"
      end
    end
  end
end