require_relative 'lib/job_bot'
require 'eventmachine'
require 'dotenv'
Dotenv.load
EM.run do 
  bot1 = JobBot.new(token: ENV["SLACK_API_TOKEN"])
  bot1.start_async
end