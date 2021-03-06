# frozen_string_literal: true

require 'nokogiri'
require 'faraday'
require_relative 'notifier'

class Job
  attr_reader :log

  def initialize
    @log = Logging.logger[self]
    @username = ENV['USERNAME']
    @healthcheck = HealthCheck.new
    @notifier = Notifier.new
  end

  def run
    @healthcheck.signal_start
    log.info 'Checking vote status'
    data = {
      name: @username,
      gtop: 'Vote'
    }

    url = 'https://mapleroyals.com/?page=vote'

    response = Faraday.post(url) do |req|
      req.headers['Content-Type'] = 'application/x-www-form-urlencoded'
      req.body = URI.encode_www_form(data)
    end
    html = response.body
    document = Nokogiri::HTML(html)
    center_text = document.xpath('//*[@id="main"]/center').css('center').text
    if center_text.include? 'You have already voted.'
      log.info 'User has already voted'
      @has_voted = true
    else
      log.info 'User has not yet voted'
      @has_voted = false
      scrape_event_notices
      @voting_link = document.xpath('//*[@id="main"]/center').css('a').attribute('href').value
      @notifier.send_notification(@voting_link, @latest_notice, @latest_event)
    end
    log.info 'Checking vote status: DONE'
    @healthcheck.signal
  end

  def voted?
    @has_voted
  end

  def scrape_event_notices
    log.info 'Scraping latest event and latest notice'
    response = Faraday.get 'https://mapleroyals.com/forum/forums/announcements.2/'
    html = response.body
    document = Nokogiri::HTML(html)
    all_threads = '//*[@id="content"]/div/div/div[4]/form[1]/ol'
    begin
      latest_notice_doc = get_first_not_sticky(document.xpath(all_threads))
      @latest_notice = {
        'text' => latest_notice_doc.text,
        'link' => "https://mapleroyals.com/forum/#{latest_notice_doc.attribute('href').value.strip}"
      }
    rescue NoMethodError => e
      log.error e.message
      log.error 'Could not scrape latest notice'
    end
    response = Faraday.get 'https://mapleroyals.com/forum/forums/events.79/'
    html = response.body
    document = Nokogiri::HTML(html)
    begin
      latest_event_doc = get_first_sticky(document.xpath(all_threads))
      @latest_event = {
        'text' => latest_event_doc.text,
        'link' => "https://mapleroyals.com/forum/#{latest_event_doc.attribute('href').value.strip}"
      }
    rescue NoMethodError => e
      log.error e.message
      log.error 'Could not scrape latest event'
    end
    log.info 'Scraping latest event and latest notice: DONE'
  end

  def get_first_not_sticky(doc)
    doc.css('li:not(.sticky)')[2].css('div')[1].css('div').css('h3').css('a')[1]
  end

  def get_first_sticky(doc)
    doc.css('li')[1].css('div')[1].css('div').css('h3').css('a')[1]
  end
end
