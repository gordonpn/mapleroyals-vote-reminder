class Dispatcher
  attr_reader :log

  def initialize
    @log = Logging.logger[self]
  end

  def start
    log.info "Dispatcher started"
    @job = Job.new
    schedule_interval
  end

  def schedule_interval
    loop do
      if Time.new.hour < 7 || Time.new.hour == 23
        @job.run
        if @job.has_voted?
          schedule_later
          break
        end
      end
      minutes = rand(60..120)
      precise_time = Time.now + (minutes * 60)
      log.info "Waiting #{minutes} minutes before next check at #{precise_time}"
      sleep(minutes * 60)
    end
  end

  def schedule_later
    vote_hour = 20
    hours_wait = (vote_hour - Time.new.hour)
    precise_time = Time.now + (hours_wait * 60 * 60)
    log.info "Next check will be in #{hours_wait} hours at #{precise_time}"
    sleep(hours_wait * 60 * 60)
    schedule_interval
  end
end
