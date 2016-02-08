# Ruby Job SlackBot 

Integrates with Reddit and WorkInStartups to deliver jobs to people right in Slack.

Three Classes:
- JobBot is the SlackBot itself and handles the routing/matching/parsing of commands
- JobGrabber holds the jobs, sources and filters content before returning it
- Job is an abstraction to create a unified API for jobs coming from Reddit and WorkInStartups, there is potential for turning this into a adaptor system for jobs coming from a lot more services

#Setup your own
You're going to need to clone the repo, you can then proceed to fill out the ENV variables you need a slack custom integration token, a reddit client and secret. 
Locally it's best to keep them in an `.env` file (with dotenv these automatically get loaded in). An example `.env` file is provided so you can run `cp .env.example .env` from the command line to set up your local environment variables.
To deploy on heroku you will need to set the variables either through the panel or with the heroku command line tools.
