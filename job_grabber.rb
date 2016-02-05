require 'redd'
require 'dotenv'
Dotenv.load

# r = Redd.it(:userless, ENV["REDDIT_CLIENT"], ENV["REDDIT_SECRET"], user_agent: "TestBot v1.0.0")
# r.authorize!
# for_hire = r.subreddit_from_name("forhire")
# puts for_hire.display_name
# puts for_hire.public_description
# new_posts = for_hire.get_new
# hiring = new_posts.select{|obj| obj[:title].include?"Hiring"}
# puts hiring.first.keys

class JobGrabber
  def initialize(sources=[], from_date=0)
    if sources.count == 0
      @sources = ['reddit:forhire', 'reddit:freelance_forhire', 'reddit:london_for_hire', 'workinstartups:co-founder']
    else
      @sources = sources
    end
    @from_date = from_date
  end
  def set_from_date date
    @from_date = date
  end
  def add_source source
    @sources.push(source)
  end
  def remove_source source
    if @sources.include?source
      @source.delete(source)
    end
  end
  def get_sources
    @sources
  end
  def get_jobs

  end
end