#!/usr/bin/env ruby
require 'rubygems'
require 'hpricot'
require 'open-uri'
require 'twitter'

# Adjust these
TWITTER_USERNAME   = "xxx"
TWITTER_PASSWORD   = "xxx"
TAG = 'iphonedev'

# But not this.
BASE_URL = 'http://wefollow.com'

def find_followers_on_url(url, previous_page = nil)
  @doc = Hpricot(open(url))

  (@doc/"a").each do |link|
    if link.attributes['href'][0..17] == 'http://twitter.com' 
      if link.attributes['class'] && link.attributes['class'] == 'fn url'
        follow(link.attributes['href'].split('/').last)
      end
    elsif link.attributes['href'].include?('/page')
      if previous_page
        previous_page_num = previous_page.scan(/\d+/).first.to_i
        if previous_page_num < link.attributes['href'].scan(/\d+/).first.to_i
          change_page(url, "#{BASE_URL}/#{link.attributes['href']}")
        end
      else
        change_page(url, "#{BASE_URL}/#{link.attributes['href']}")
      end
    end
  end
end

def follow(username)
  twitter = Twitter::Client.new(:login => TWITTER_USERNAME, :password => TWITTER_PASSWORD)
  begin
    twitter.friend(:add, username)
    puts "Now following: #{username}"
  rescue Exception => e
    puts "There was a problem adding #{username}: #{e}"
  end
end

def change_page(current_page, next_page)
  puts "Changing pages to #{next_page}"
  find_followers_on_url(next_page, current_page)
end

find_followers_on_url("#{BASE_URL}/tag/#{TAG}")