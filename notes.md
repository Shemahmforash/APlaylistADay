#Goals
Present a playlist a day in the formats:
* Website
* Webservice

#How
* Find events for a particular day in the history of music
* Get artist in each event - using [Echonest extract artist API](http://developer.echonest.com/docs/v4/artist.html#extract-beta)
* Get a song for each of the artist from youtube - using [Echonest artist video API](http://developer.echonest.com/docs/v4/artist.html#video)

#Problems
* Always get the events from an external service, or save them in a DB?
    * Keep the in a DB improves speed
    * Although the events in the website can be added
    * Should save in db when checking for the first time, then retrieve from the DB. Altough once a day, perform cleaning of DB, to allow for changes in the source website.
* Improve the finding a youtube video for an artist, because actually:
    * Sometimes fails and gets a video not of the artist chosen
    * Should I use topic-based search?
* Implement Object Oriented way of working using the classes I have already created
* Implement pagination, or else the site will be stuck for a long time...
* Currently, I am limited to 20 echonest api calls a minute... Try to ask for more, implement pagination, or get back to youtube api.
* Create tests for the classes
* Depploy the application to heroku

#Interface
* To be created yet
* Altough the request to the events shoud be from ajax. In this way, the respond_to('html') should render the page right away and in the ajax, the respond_to('json') of the same address should be called with pagination options.
