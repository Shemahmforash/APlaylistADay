APlaylistADay
=============

A web app and service that each day generates a new playlist with songs based on events that happened on this day in history/music.

#Flow
* Finds events that happened in a particular day in the history of music
* Finds an artist for each of the events
* Generates a song for each of the artists

#Requirements
 It requires the following perl packages that you can find on cpan:
* [Mojolicious](http://search.cpan.org/~sri/Mojolicious-4.24/lib/Mojolicious.pm)
* [Moose](http://search.cpan.org/~ether/Moose-2.1005/lib/Moose.pm)
* [MooseX::Privacy](http://search.cpan.org/~franckc/MooseX-Privacy-0.05/lib/MooseX/Privacy.pm)
* [WebService::EchoNest](http://search.cpan.org/~nickl/WebService-EchoNest-0.007/lib/WebService/EchoNest.pm)
* [JSON](http://search.cpan.org/~makamaka/JSON-2.90/lib/JSON.pm)
* [LWP::UserAgent](http://search.cpan.org/~gaas/libwww-perl-6.05/lib/LWP/UserAgent.pm)
* [LWP::Protocol::https](http://search.cpan.org/~gaas/LWP-Protocol-https-6.04/lib/LWP/Protocol/https.pm)
* [DateTime](http://search.cpan.org/~drolsky/DateTime-1.03/lib/DateTime.pm)
* [Redis](http://search.cpan.org/~dams/Redis-1.965/lib/Redis.pm)
* [Date::Parse](http://search.cpan.org/~gbarr/TimeDate-2.30/lib/Date/Parse.pm)

#Installation
 1. Install cpanminus. On a Debian-based Linux distribution you can do:
     `sudo apt-get install cpanminus`
 2. Install every perl module in the requirements section using cpanminus

``` bash
    sudo cpanm Mojolicious Moose MooseX::Privacy WebService::EchoNest JSON LWP::UserAgent LWP::Protocol::https DateTime Redis Date::Parse
```
 3. Clone this project:
    `git clone https://github.com/Shemahmforash/APlaylistADay.git`
 4. Change to the directory of the application:
    `cd APlaylistADay`
 5. Run the application using:
    `morbo script/aplaylist_aday`
 6. Go to http://127.0.0.1:3000/ and see the program running
