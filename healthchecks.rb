class HealthChecks
  attr_reader :log

  def initialize
    @log = Logging.logger[self]
    @uuid = ENV["HEALTHCHECK_UUID"]
  end

  def signal(status = "")
    return if ENV["DEV"]
    log.info "Signaling healthcheck #{status}"
    url = "https://hc-ping.com/#{@uuid}#{status}"
    response = Faraday.get url
    raise StandardError.new "Healthcheck status not ok" unless response.success?
    log.info "Signaling healthcheck: Done"
  end

  def signal_start
    signal("/start")
  end

  def signal_fail
    signal("/fail")
  end
end
