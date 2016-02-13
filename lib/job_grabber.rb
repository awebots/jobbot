require_relative 'src_grabber'
require 'thread'
class JobGrabber
  def initialize(sources)
    @sources = sources
  end
  def grab
    jobs = Array.new
    mutex = Mutex.new
    threads = Array.new
    @sources.each do |src|
      threads << Thread.new(src, jobs) do |src, jobs|
        src_jobs = SrcGrabber.new(src).grab
        mutex.synchronize{jobs += src_jobs}
      end
    end
    threads.each(&:join)
    jobs
  end
end