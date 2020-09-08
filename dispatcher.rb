class Dispatcher
  attr_reader :log

  def initialize
    @log = Logging.logger[self]
  end

  def start
    log.info "Dispatcher started"
    @job = Job.new
    @time = Time.new
    schedule_interval
  end

  def schedule_interval
    loop do
      @job.run
      if @job.has_voted?
        schedule_later
        break
      end
      minutes = rand(60..120)
      precise_time = Time.now + (minutes * 60)
      log.info "Waiting #{minutes} minutes before next check at #{precise_time}"
      sleep(minutes * 60)
    end
  end

  def schedule_later
    vote_hour = 20
    hours_wait = (vote_hour - @time.hour)
    precise_time = Time.now + (hours_wait * 60 * 60)
    log.info "Next check will be in #{hours_wait} hours at #{precise_time}"
    sleep(hours_wait)
    schedule_interval
  end
end
