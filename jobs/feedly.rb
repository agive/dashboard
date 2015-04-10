require "json"
require "uri"
require "net/http"

SCHEDULER.every "30m" do
  logger = Logger.new("feedly")
  logger.start
  begin
    headers = {
      "Authorization" => "OAuth #{ENV["FEEDLY_TOKEN"]}"
    }

    uri = URI.parse("http://cloud.feedly.com/v3/markers/counts")
    http = Net::HTTP.new(uri.host, uri.port)
    response = http.get(uri.path, headers)
    response_hash = JSON.parse(response.body)
    unread_counts = response_hash["unreadcounts"]
    reading_count = unread_counts.find do |unread_count|
      unread_count["id"].include?("category/Reading")
    end
    send_event('rss', { current: reading_count["count"] })
  rescue Exception => e
    logger.exception(e)
  end
  logger.end
end
