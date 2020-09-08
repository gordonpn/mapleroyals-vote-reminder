require 'logging'
require 'dotenv'
require_relative 'job'
Dotenv.load

Logging.logger.root.level = ENV['DEV'] ? :debug : :info
Logging.logger.root.appenders = Logging.appenders.stdout

class ReminderService
  attr_reader :log
  def initialize
    @log = Logging.logger[self]
  end
end

job = Job.new
job.log.debug 'ayy lmao'
