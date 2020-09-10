# frozen_string_literal: true

require 'logging'
require 'dotenv'
require_relative 'job'
require_relative 'dispatcher'
require_relative 'healthcheck'

Dotenv.load
Logging.logger.root.level = ENV['DEV'] ? :debug : :info
Logging.logger.root.appenders = Logging.appenders.stdout

def shut_down
  puts "\nShutting down gracefully..."
  sleep 1
end

Signal.trap('INT') do
  shut_down
  exit
end

Signal.trap('TERM') do
  shut_down
  exit
end

begin
  dispatcher = Dispatcher.new
  dispatcher.start
rescue StandardError => e
  puts "Exception Occurred #{e}. Message: #{e.message}. Backtrace:  \n #{e.backtrace.join("\n")}"
  healthcheck = HealthCheck.new
  healthcheck.signal_fail
  raise
end
