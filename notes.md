#Goals
Present a playlist a day in the formats:
* Website
* Webservice

#How
* Find events for a particular day in the history of music
* Get artist in each event - using [Echonest extract artist API](http://developer.echonest.com/docs/v4/artist.html#extract-beta)
* Get a song for each of the artist from youtube - using [Echonest artist video API](http://developer.echonest.com/docs/v4/artist.html#video) or [Youtube API](https://www.googleapis.com/youtube/v3/search)

#Problems
* Always get the events from an external service, or save them in a DB?
    * Keep the in a DB improves speed
    * Although the events in the website can be added
* Improve the finding a youtube video for an artist, because actually:
    * Sometimes fails and gets a video not of the artist chosen
* Create tests for the classes
* Depploy the application to heroku

#Interface
* To be created yet
* Altough the request to the events shoud be from ajax. In this way, the respond_to('html') should render the page right away and in the ajax, the respond_to('json') of the same address should be called with pagination options.
