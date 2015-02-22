require 'json'
require 'pp'

username = ENV["STATUSCAKE_USERNAME"]
key = ENV["STATUSCAKE_KEY"]

SCHEDULER.every "#{ENV["UPDATE_FREQUENCY"]}" do
  items=[]
  is_down=0
  overall_status='ok'
  response = Net::HTTP.get_response(URI('https://www.statuscake.com/API/Tests/?Username='+username+'&API='+key))
  all_tests = JSON.parse(response.body)
  test_ids = all_tests.map do |site_test|
    site_test["TestID"]
  end
  test_ids.each do |testid|
    response = Net::HTTP.get_response(URI("https://www.statuscake.com/API/Tests/Details/?TestID=#{testid}&Username=#{username}&API=#{key}"))
    website = JSON.parse(response.body)
    if website['Status']!='Up'
      items << { site: website['WebsiteName'], status: website['Status'], lasttest: website['LastTested'] }
      overall_status='warning'
    end
  end
  send_event('statuscake', { items:items, overall_status: overall_status })
end
