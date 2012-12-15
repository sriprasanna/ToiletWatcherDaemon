require 'tweetstream'
require 'json'
require 'net/http'

URL = "http://api.twitter.com/1/statuses/user_timeline.json?include_entities=true&include_rts=true&screen_name=SanHackTwToilet&count=10"
POST_URL = "http://localhost:3000/location"
last_parsed_ID = 0

EM.run do
  EM::PeriodicTimer.new(10) do
    p "*"*100
    resp = Net::HTTP.get_response(URI.parse(URL))
    data = resp.body
    results = JSON.parse(data)
    results.reverse.each do |result|
      if last_parsed_ID < result['id']
        text = result['text'].split
        location = text.first
        toilet_count, wash_basin_count, water_level = text.reject{ |i| !i.match(/\d/) }.collect(&:to_i)
        tweet = { :name => location,
                  :time => result['created_at'],
                  :toilet_count => toilet_count,
                  :wash_basin_count => wash_basin_count,
                  :water_level => water_level
                }
        p tweet
        res = Net::HTTP.post_form(URI.parse(POST_URL), tweet)
        last_parsed_ID = result['id']
      end
    end
  end
end