require 'chronic'
require 'dotenv'
Dotenv.load

require 'slack-ruby-bot'
require_relative 'job_grabber'

class JobBot < SlackRubyBot::Bot
  def initialize (options = {})
    @@job_grabber = JobGrabber.new
    p @@job_grabber
  end
  # source management
  match /^add source (?<source>\S*)$/ do |client, data, match|
    @@job_grabber.add_source match[:source]
    client.say(text: @@job_grabber.get_sources, channel: data.channel)
  end
  match /^remove source (?<source>\S*)$/ do |client, data, match|
    source = match[:source]
    @@job_grabber.remove_source source
    client.say(text: "Removed " + source)
  end
  # job queries
  match /^jobs in (?<category>\S*)$/ do |client, data, match|
    client.say(text: match[:category], channel: data.channel)
  end
  match /^jobs (from )?(?<date>\w*)$/ do |client, data, match|
    raw_date = match[:date].gsub("_"," ")
    from_date = Chronic.parse(raw_date)
    client.say(text: "Jobs from: " + from_date, channel: data.channel)
  end

  command 'sources' do |client, data, match|
    reply = "Sources:\n" + @@job_grabber.get_sources.join("\n")
    client.say(text: reply, channel: data.channel)
  end
  command 'hello' do |client, data, match|
    client.say(text: 'Hello there!!!', channel: data.channel)
  end
  command 'jobs' do |client, data, match|
    client.say(text: 'for hire', channel: data.channel)
  end
end

bot = JobBot.new
bot.class.run