require 'httparty'
require 'nokogiri'

# 1. Отримуємо HTML сторінки
url = "https://uk.wikipedia.org/wiki/" # (замініть на ваш сайт)
response = HTTParty.get(url)

if response.code == 200
  puts "Сторінка успішно завантажена!"

  doc = Nokogiri::HTML(response.body)

  title = doc.css('h1').text
  puts "Заголовок сторінки: #{title}"

else
  puts "Помилка при завантаженні сторінки: #{response.code}"
end