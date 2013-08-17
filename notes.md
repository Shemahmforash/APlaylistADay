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
* Use another events website or try to extend the parse of the current one to include birthdays and deaths
    * Note that this is in an external application: [ThisDayIn](https://github.com/Shemahmforash/ThisDayIn)
* Improve the finding a youtube video for an artist, because actually:
    * Sometimes fails and gets a video not of the artist chosen
    * There is no randomness - for the same artist in different events it gets always the same video
    * Should I use topic-based search?
* Implement Object Oriented way of working using the classes I have already created
* Create tests for the classes
* Depploy the application to heroku
