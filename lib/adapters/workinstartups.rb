require 'workinstartups-api'
require_relative '../job'
module Adapters
  module Workinstartups
    extend self
    def grab source
      workinstartups_name = source
      category = WorkInStartupsAPI.category_from_string(workinstartups_name)
      api = WorkInStartupsAPI.new(category, 100)
      hiring = api.get_latest(false)
      jobs = Array.new
      hiring.each do |job|
        jobs << Job.new('workinstartups:' + source, job["id"], job["title"], job["description"], DateTime.parse(job["mysql_date"]).to_s, "http://workinstartups.com/job-board/job/" + job["id"])
      end
      jobs
    end
  end
end