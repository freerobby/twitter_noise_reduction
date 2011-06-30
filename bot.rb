require "rubygems"
require "bundler/setup"

require "tweetstream"
require "twitter"

FILTER_PHRASES = ENV['TWITTER_BOT_FILTER_PHRASES'].downcase.split(";").map{|x| x.strip}

Twitter.configure do |config|
  config.consumer_key = ENV['TWITTER_BOT_CONSUMER_KEY']
  config.consumer_secret = ENV['TWITTER_BOT_CONSUMER_SECRET']
  config.oauth_token = ENV['TWITTER_BOT_OAUTH_KEY']
  config.oauth_token_secret = ENV['TWITTER_BOT_OAUTH_SECRET']
end
TWITTER_BOT_REPLICATES = ENV['TWITTER_BOT_REPLICATES']

target_twitter_id = Twitter.user(TWITTER_BOT_REPLICATES).id
TweetStream::Client.new(ENV['TWITTER_BOT_USERNAME'], ENV['TWITTER_BOT_PASSWORD']).follow(target_twitter_id) do |status, client|
  found_a_hit = true
  found_a_hit = false if status.user.screen_name.downcase != TWITTER_BOT_REPLICATES.downcase # Filter out 3rd party @-replies and our own retweets
  if found_a_hit # Only necessary if this status hasn't already been negated.
    FILTER_PHRASES.map do |phrase|
      found_a_hit = false if status.text.downcase.include?(phrase)
    end
  end
  Twitter.retweet(status.id) if found_a_hit
end
