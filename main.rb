require 'nokogiri'
require 'faraday'

data = {
  :name => "gordonpnn",
  :gtop => "Vote"
}

url = "https://mapleroyals.com/?page=vote"

response = Faraday.post(url) do |req|
  req.headers['Content-Type'] = 'application/x-www-form-urlencoded'
  req.body = URI.encode_www_form(data)
end
html = response.body
document = Nokogiri::HTML(html)
already_voted_message = document.xpath("//*[@id=\"main\"]/center").css("center").text
if already_voted_message.include? "You have already voted."
  puts "User has already voted"
  return
end
puts "User has not yet voted"
voting_link = document.xpath("//*[@id=\"main\"]/center").css("a").attribute("href").value
puts voting_link
