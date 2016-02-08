# Ruby SlackBot that integrates with Reddit and WorkInStartups to deliver jobs to people right in Slack

Three Classes:
- JobBot is the SlackBot itself and handles the routing/matching/parsing of commands
- JobGrabber holds the jobs, sources and filters content before returning it
- Job is an abstraction to create a unified API for jobs coming from Reddit and WorkInStartups