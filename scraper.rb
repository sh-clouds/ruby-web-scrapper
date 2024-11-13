require "nokogiri"
require "httparty"
require "csv"
require 'json'

# get the target page
url_title = "https://brightdata.com"
#best response
begin
  response = HTTParty.get(url_title, {

    headers: { "User-Agent" => "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/112.0.0.0 Safari/537.36"},

  })
rescue OpenURI::HTTPError => e
  puts "Ошибка при открытии URL: #{e.message}"
end

# scraping logic...
doc = Nokogiri::HTML(response.body)

UseCase = Struct.new(:image, :url, :name)

# initialize the list of objects
# that will store all retrieved data
use_cases = []

# select all use case HTML elements
use_case_cards = doc.css(".cards .card_wrapper")

#puts use_case_cards.inspect
# iterate over the HTML cards
use_case_cards.each do |use_case_card|

  # extract the data of interest
  image_pre = use_case_card.at_css("img").attribute("data-lazy-src")
  if image_pre
    image = image_pre.value
  else
    image = ''
  end 


  url_pre = use_case_card.at_css(".card").attribute("href")
  if url_pre
    url = url_title + url_pre.value
  else
    url = ''
  end 

  name_pre = use_case_card.at_css(".card__content")
  if name_pre
    name = name_pre.text
  else
    name = ''
  end   

  # instantiate an UseCase object with the
  # collected data
  use_case = UseCase.new(url, image, name)

  # add the UseCase instance to the array
  # of scraped objects
  use_cases.push(use_case)
  #puts image.inspect
  #puts url.inspect 
  #puts name.inspect    
end

# populate the CSV output file
CSV.open("output.csv", "wb") do |csv|

  # write the CSV header
  csv << ["url", "image", "name"]

  # transfrom each use case scraped info to a
  # CSV record
  use_cases.each do |use_case|
    csv << use_case
  end
end

# propulate the JSON output file

File.open("output.json", "wb") do |json|
  json << JSON.pretty_generate(use_cases.map { |u| Hash[u.each_pair.to_a] })
end

#use_cases[0]
#puts use_cases[0].inspect

#number use_cases
print "quantity use cases #{use_cases.length}\n"


#test 
#puts "Test ok!"