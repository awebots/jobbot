require_relative 'job_grabber'
class JobController
  DEFAULT_FORMAT = "created_at id title link"
  DEFAULT_NUMBER = 5
  DEFAULT_SOURCES = [ 
    # 'reddit:forhire', 
    # 'reddit:freelance_forhire', 
    'reddit:london_forhire', 
    'workinstartups:co-founder',
    'workinstartups:programmer',
    'hackernews:jobs'
  ]
  
  def initialize(sources = DEFAULT_SOURCES, format = DEFAULT_FORMAT, number = DEFAULT_NUMBER)
    @sources = sources
    @format = format
    @jobs = Array.new
    @formatted_jobs = Array.new
    @number = number
    @jobs = JobGrabber.new(@sources).grab
  end
  def add_source source
    @sources.push(source)
    @jobs = JobGrabber.new(@sources).grab
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