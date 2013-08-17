#Goals
Present a playlist a day in the formats:
* Website
* Webservice

#How
* Find events for a particular day in the history of music
* Get artist events
* Get a song for each of the artist from youtube (or spotify or other service)

#Problems
* Always get the events from an external service, or save them in a DB?
    * Keep the in a DB improves speed
    * Although the events in the website can be added
* Improve the finding a youtube video for an artist, because actually:
    * Sometimes fails and gets a video not of the artist chosen
    * Should I use topic-based search?
* Implement Object Oriented way of working using the classes I have already created
* Implement pagination, or else the site will be stuck for a long time...
* Currently, I am limited to 20 echonest api calls a minute... Try to ask for more, implement pagination, or get back to youtube api.
* Create tests for the classes
* Depploy the application to heroku
