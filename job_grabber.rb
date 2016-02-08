require 'dotenv'
Dotenv.load
require 'redd'
require 'workinstartups-api'
require_relative 'job'
class JobGrabber
  DEFAULT_FORMAT = "created_at id title link"
  DEFAULT_NUMBER = 5
  DEFAULT_SOURCES = [ 
    # 'reddit:forhire', 
    # 'reddit:freelance_forhire', 
    'reddit:london_forhire', 
    'workinstartups:co-founder',
    'workinstartups:programmer'
  ]
  
  def initialize(sources = DEFAULT_SOURCES, format = DEFAULT_FORMAT, number = DEFAULT_NUMBER)
    @sources = sources
    @format = format
    @jobs = Array.new
    @formatted_jobs = Array.new
    @number = number
    if @sources.join('').include?"reddit"
      @r ||= Redd.it(:userless, ENV["REDDIT_CLIENT"], ENV["REDDIT_SECRET"], user_agent: "JobGrabber v1.0.0")
      @r.authorize!
      store_reddit_jobs
    end
    if @sources.join('').include?"workinstartups"
      store_workinstartups_jobs
    end
  end
  def add_source source
    @sources.push(source)
    if source.include?"reddit"
      store_reddit_jobs
    end
    if source.include?"workinstartups"
      store_workinstartups_jobs
    end
  end
  def remove_source source
    @sources.select!{|src| !src.include?source}
    @jobs.select!{|job| !job.origin.include?source}
  end
  def set_number number
    @number = Integer(number)
  end
  def get_sources with_count = false
    unless with_count
      @sources
    end
  end
  def set_format format
    @format = format
  end
  def get_job_count
    @jobs.count
  end
  def store_reddit_jobs
    @sources.each do |s|
      if s.start_with?"reddit"
        subreddit_name = s.split(":").last
        subreddit = @r.subreddit_from_name(subreddit_name)
        last_job = @jobs.select{|job| job.origin == s}.last
        last_create = (last_job.nil?)? false : DateTime.parse(last_job.created_at)
        hiring = subreddit.get_new.select{|obj| obj[:title].downcase.include?"hiring"}
        hiring.each do |job|
          if last_create and Time.at(job[:created_utc]).to_datetime < last_create
            break
          end
          @jobs << Job.new(s, job[:id], job[:title], job[:selftext], Time.at(job[:created_utc]).to_datetime.to_s, "http://reddit.com" + job[:permalink])
        end
      end
    end
    @jobs
  end
  def store_workinstartups_jobs
    @sources.each do |s|
      if s.start_with?"workinstartups"
        workinstartups_name = s.split(":").last
        category = WorkInStartupsAPI.category_from_string(workinstartups_name)
        api = WorkInStartupsAPI.new(category, 100)
        last_job = @jobs.select{|job| job.origin == s}.last
        last_create = (last_job.nil?)? false : DateTime.parse(last_job.created_at)
        jobs = api.get_latest(false)
        jobs.each do |job|
          if last_create and DateTime.parse(job["mysql_date"]) < last_create
            break
          end
          @jobs << Job.new(s, job["id"], job["title"], job["description"], DateTime.parse(job["mysql_date"]).to_s, "http://workinstartups.com/job-board/job/" + job["id"])
        end
      end
    end
  end
  def get_jobs_from_date date
    @jobs.select{|job| DateTime.parse(job.created_at) > date}.sort{|a,b|a.created_at<=>a.created_at}.map{|job| job.format(@format)}[0...@number]
  end
  def get_jobs_formatted
    @jobs.sort{|a,b|a.created_at<=>a.created_at}.map{|job| job.format(@format)}[0...@number]
  end
  def get_job id
    @jobs.detect{|job| job.id == id}.format(@format)
  end
  def get_by_source source
    if !@source.include?source
      raise "Source unknown, add it to the source list first"
    end
    @jobs.select{|job| job.origin == source}.sort{|a,b|a.created_at<=>a.created_at}.map{|job| job.format(@format)}
  end
  def get_by_category category
    category = category.downcase
    @jobs.select{|job| job.description.downcase.include?category}.sort{|a,b|a.created_at<=>a.created_at}.map{|job| job.format(@format)}[0...@number]
  end
end