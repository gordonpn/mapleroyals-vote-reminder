require "logging"
require "dotenv"
require_relative "job"
require_relative "dispatcher"
require_relative "healthchecks"

Dotenv.load
Logging.logger.root.level = ENV["DEV"] ? :debug : :info
Logging.logger.root.appenders = Logging.appenders.stdout

def shut_down
  puts "\nShutting down gracefully..."
  sleep 1
end

Signal.trap("INT") {
  shut_down
  exit
}

Signal.trap("TERM") {
  shut_down
  exit
}

begin
  dispatcher = Dispatcher.new
  dispatcher.start
rescue => e
  puts "Exception Occurred #{e}. Message: #{e.message}. Backtrace:  \n #{e.backtrace.join("\n")}"
  healthchecks = HealthChecks.new
  healthchecks.signal_fail
  raise
end
