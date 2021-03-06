# frozen_string_literal: true

class HealthCheck
  attr_reader :log

  def initialize
    @log = Logging.logger[self]
    @uuid = ENV['HEALTHCHECK_UUID']
    raise StandardError, 'Healthcheck UUID cannot be empty' if @uuid.to_s.empty? && !ENV.key?('DEV')
  end

  def signal(status = '')
    return if ENV.key?('DEV')

    log.info "Signaling healthcheck #{status}"
    url = "https://hc-ping.com/#{@uuid}#{status}"
    response = Faraday.get url
    raise StandardError, 'Healthcheck status not ok' unless response.success?

    log.info 'Signaling healthcheck: DONE'
  end

  def signal_start
    signal('/start')
  end

  def signal_fail
    signal('/fail')
  end
end
