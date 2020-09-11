# frozen_string_literal: true

class Dispatcher
  attr_reader :log

  def initialize
    @log = Logging.logger[self]
  end

  def start
    log.info 'Dispatcher started'
    @job = Job.new
    schedule_interval unless ENV.key?('DEV')
    @job.run if ENV.key?('DEV')
  end

  def schedule_interval
    loop do
      log.info "Current Time is #{Time.new.inspect}"
      @job.run
      return schedule_later if @job.voted?
      return schedule_later(7) if Time.new.hour > 6 && Time.new.hour != 23

      minutes = rand(60..120)
      precise_time = Time.now + (minutes * 60)
      log.info "Waiting #{minutes} minutes before next check at #{precise_time}"
      sleep(minutes * 60)
    end
  end

  def schedule_later(resume_hour = 20)
    hour_now = Time.new.hour
    hours_wait = if hour_now >= resume_hour
                   24 - (hour_now - resume_hour)
                 else
                   (resume_hour - hour_now)
                 end
    precise_time = Time.now + (hours_wait * 60 * 60)
    log.info "Next check will be in #{hours_wait} hours at #{precise_time}"
    sleep(hours_wait * 60 * 60)
    schedule_interval
  end
end
