require "logging"
require "dotenv"
require_relative "job"
require_relative "dispatcher"

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

dispatcher = Dispatcher.new
dispatcher.start
