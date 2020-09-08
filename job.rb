require "nokogiri"
require "faraday"

class Job
  attr_reader :log

  def initialize
    @log = Logging.logger[self]
    @username = ENV["USERNAME"]
  end

  def run
    log.info "Vote status check started"
    data = {
      :name => @username,
      :gtop => "Vote",
    }

    url = "https://mapleroyals.com/?page=vote"

    response = Faraday.post(url) do |req|
      req.headers["Content-Type"] = "application/x-www-form-urlencoded"
      req.body = URI.encode_www_form(data)
    end
    html = response.body
    document = Nokogiri::HTML(html)
    center_text = document.xpath("//*[@id=\"main\"]/center").css("center").text
    if center_text.include? "You have already voted."
      log.info "User has already voted"
      @has_voted = true
    else
      log.info "User has not yet voted"
      @has_voted = false
      @voting_link = document.xpath("//*[@id=\"main\"]/center").css("a").attribute("href").value
    end
    log.info "Vote status check ended"
  end

  def has_voted?
    @has_voted
  end
end
