require 'hnjobs'
require_relative '../job'
module Adapters
  module Hackernews
    extend self
    def grab source
      hiring = HNJobs.new.jobs
      jobs = Array.new
      hiring.each do |job|
        jobs << Job.new('hackernews:' + source, job["id"].to_s, job["title"], job["text"], Time.at(job["time"]).to_datetime.to_s, (job["url"].nil?)? "" : job["url"])
      end
      jobs
    end
  end
end