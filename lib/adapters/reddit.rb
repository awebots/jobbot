require 'dotenv'
Dotenv.load
require 'redd'
require_relative '../job'
module Adapters
  module Reddit
    extend self
    def grab source
      @r ||= Redd.it(:userless, ENV["REDDIT_CLIENT"], ENV["REDDIT_SECRET"], user_agent: "JobGrabber v1.0.0")
      @r.authorize!
      subreddit_name = source
      subreddit = @r.subreddit_from_name(subreddit_name)
      
      hiring = subreddit.get_new.select{|obj| obj[:title].downcase.include?"hiring"}
      jobs = Array.new
      hiring.each do |job|
        jobs << Job.new('reddit:' + source, job[:id], job[:title], job[:selftext], Time.at(job[:created_utc]).to_datetime.to_s, "http://reddit.com" + job[:permalink])
      end
      jobs
    end
  end
end