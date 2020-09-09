require "json"

class Notifier
  attr_reader :log

  def initialize
    @log = Logging.logger[self]
    @url = ENV["SLACK_NOTIFIER_URL"]
    raise StandardError.new "Slack webhook URL cannot be empty" if @url.to_s.empty?
  end

  def send_notification(link, latest_notice, latest_event)
    raise StandardError.new "Link cannot be empty" if link.to_s.strip.empty?
    raise StandardError.new "Latest notice hash cannot be empty" if hash_has_blank(latest_notice)
    raise StandardError.new "Latest event hash cannot be empty" if hash_has_blank(latest_event)

    log.info "Sending notification to user"

    form_data = {
      text: "You have not yet voted for MapleRoyals today.",
      blocks: [
        {
          type: "section",
          text: {
            type: "mrkdwn",
            text: "*You have not yet voted for MapleRoyals today.*",
          },
        },
        {
          type: "actions",
          elements: [
            {
              type: "button",
              text: {
                type: "plain_text",
                text: "Click to vote",
                emoji: true,
              },
              url: link,
            },
          ],
        },
        {
          type: "divider",
        },
        {
          type: "header",
          text: {
            type: "plain_text",
            text: "Latest events and notices",
            emoji: true,
          },
        },
        {
          type: "section",
          text: {
            type: "mrkdwn",
            text: "<#{latest_event["link"]}|#{latest_event["text"]}>",
          },
        },
        {
          type: "section",
          text: {
            type: "mrkdwn",
            text: "<#{latest_notice["link"]}|#{latest_notice["text"]}>",
          },
        },
      ],
    }.to_json

    response = Faraday.post(@url, form_data, "Content-Type" => "application/json")
    raise StandardError.new "Slack webhook notification status not ok" unless response.success?
    log.info "Sending notification to user: DONE"
  end

  def hash_has_blank(hsh)
    hsh.values.any? &:empty?
  end
end
