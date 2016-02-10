require_relative 'src_grabber'
class JobGrabber
  def initialize(sources)
    @sources = sources
  end
  def grab
    jobs = Array.new
    @sources.each do |src|
      jobs += SrcGrabber.new(src).grab
    end
    jobs
  end
end