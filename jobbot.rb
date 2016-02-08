require 'chronic'
require 'dotenv'
Dotenv.load

require 'slack-ruby-bot'
require_relative 'job_grabber'

class JobBot < SlackRubyBot::Bot
  def initialize (options = {})
    @@job_grabber = JobGrabber.new
  end
  # source management
  match /^add src:(?<source>\S*)$/ do |client, data, match|
    source = match[:source]
    @@job_grabber.add_source source
    client.say(text: @@job_grabber.get_sources, channel: data.channel)
  end
  match /^remove src:(?<source>\S*)$/ do |client, data, match|
    source = match[:source]
    @@job_grabber.remove_source source
    client.say(text: "Removed source: " + source, channel: data.channel)
  end
  command 'src' do |client, data, match|
    reply = "Sources:\n" + @@job_grabber.get_sources.join("\n")
    client.say(text: reply, channel: data.channel)
  end
  match /^jobs limit:(?<number>\w*)$/ do |client, data, match|
    number = match[:number]
    @@job_grabber.set_number(number)
    reply = "Job limit set to " + number
    client.say(text: reply, channel: data.channel)
  end
  command 'jobs refresh' do |client, data, match|
    client.say(text: "Refreshing the jobs, please wait...", channel: data.channel)
    sources = @@job_grabber.get_sources
    @@job_grabber = JobGrabber.new(sources)
    reply = "Refreshed the jobs, there are now " + @@job_grabber.get_job_count.to_s + " jobs"
    client.say(text: reply, channel: data.channel)
  end
  # job queries
  match /^jobs src:(?<source>\w*)$/ do |client, data, match|
    source = match[:source]
    jobs = @@job_grabber.get_by_source(source).join("\n\n")
    reply = "Jobs from " + source + "\n" + jobs
    client.say(text: reply, channel: data.channel)
  end
  match /^jobs in:(?<category>\S*)$/ do |client, data, match|
    category = match[:category]
    jobs = @@job_grabber.get_by_category(category).join("\n\n")
    reply = "Jobs in " + category + ":\n" + jobs
    client.say(text: reply, channel: data.channel)
  end
  command 'jobs count' do |client, data, match|
    reply = @@job_grabber.get_job_count.to_s + " jobs"
    client.say(text: reply, channel: data.channel)
  end
  match /^jobs (from:)?(?<date>\w*)$/ do |client, data, match|
    raw_date = match[:date].gsub("_"," ")
    Time.zone = "UTC"
    Chronic.time_class = Time.zone
    date = Chronic.parse(raw_date)
    jobs = @@job_grabber.get_jobs_from_date(date).join("\n")
    client.say(text: "Jobs from: " + date.to_s + "\n"+ jobs, channel: data.channel)
  end
  match /^job (?<id>\w*)$/ do |client, data, match|
    @@job_grabber.set_format "id title link description"
    job = @@job_grabber.get_job(match[:id])
    @@job_grabber.set_format JobGrabber::DEFAULT_FORMAT
    client.say(text: "Job: " + job, channel: data.channel)
  end
  command 'jobs' do |client, data, match|
    jobs = @@job_grabber.get_jobs_formatted.join("\n")
    reply = "Jobs:\n" + jobs
    client.say(text: reply, channel: data.channel)
  end

  command 'hello' do |client, data, match|
    reply = "Hey there, here are a few commands to get you started, use `help` for more :)" + "\n"
    reply += "`jobs` gives you a set of jobs" + "\n"
    reply += "`job <id>` gives you a more in-depth description of the job" + "\n"
    reply += "`jobs count` does what is says on the tin" + "\n"
    reply += "`jobs refresh` will refetch all the jobs from the currently active sources" + "\n"
    client.say(text: reply, channel: data.channel)
  end
  command 'help' do |client, data, match|
    reply = "There are a bunch of commands: " + "\n"
    reply += "`jobs` gives you a set of jobs" + "\n"
    reply += "`job <id>` gives you a more in-depth description of the job" + "\n"
    reply += "`jobs count` does what is says on the tin" + "\n"
    reply += "`jobs refresh` will refetch all the jobs from the currently active sources" + "\n\n"
    reply += "Advanced features" + "\n"
    reply += "Filtering: " + "\n"
    reply += "`jobs in:<category>` filters by keyword present in the description of jobs (eg. `jobs in mysql`)" +"\n"
    reply += "`jobs from:<date>` or `jobs <date>` gets jobs posted since 'date' (eg. `jobs from 01/01/2016` or `jobs today`) NOTE: you can't have whitespaces so use underscores or hyphens instead" + "\n"
    reply += "`jobs src:<source>` will filter to an individual source without removing/adding all the sources" + "\n"
    reply += "Modifying the sources: " + "\n"
    reply += "`src` shows you where we're getting the jobs from" + "\n"
    reply += "`add src:<name>` with `name` in the form `reddit:<subreddit>` or `workinstartups:<category>`" +"\n"
    reply += "`remove src:<name>` removes any source that contains `name` eg. `remove source reddit` will delete `reddit:for_hire`, `reddit:freelance_forhire`..." +"\n"
    reply += "Extra settings" + "\n"
    reply += "`jobs limit:<number>` sets the maximum number of jobs displayed per command" + "\n"
    client.say(text: reply, channel: data.channel)
  end
end

bot = JobBot.new
bot.class.run