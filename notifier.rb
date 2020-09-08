class Notifier
  attr_reader :log

  def initialize
    @log = Logging.logger[self]
  end
end
