# Load the rails application
require File.expand_path('../application', __FILE__)
require 'rubygems'
require 'oauth'
require 'twitter_oauth'
$consumer = OAuth::Consumer.new(CONSUMER_KEY, CONSUMER_SECRET, :site => "http://twitter.com")
$client = TwitterOAuth::Client.new(
    :consumer_key => CONSUMER_KEY,
    :consumer_secret => CONSUMER_SECRET
)

# Initialize the rails application
CallBank::Application.initialize!
