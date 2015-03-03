# Note Taking On The Go With Twilio and the Evernote API - Part Two

![Twilio + Evernote = ♥](http://cl.ly/image/3R3r452L3C08/twilio_plus_evernote.png)

This is the code repo for a blog post on how your can Twilio and the Evernote API to allow you to create a note in Evernote from an SMS or MMS message as well as creating voicemail from an incoming call. I highly encourage you to walk through the entire tutorial to get this software up-and-running on a server of your choice.

If you have any questions or run into a problem, please feel free to file an issue. 

Thanks!

## Setup

Here's what you'll need to get started:

* A [Twilio](http://twilio.com) account that can send and receive SMS messages - [create one free here](http://twilio.com/try-twilio)
* [Evernote API and Developer Key](https://dev.evernote.com/#apikey)
* [Evernote Sandbox Account](http://sandbox.evernote.com)

The blog post that accompanies this repo describes how to set up the developer key and Evernote Sandbox account.

If you want to jump right into using this right now, use the Heroku Button below:

[![Deploy](https://www.herokucdn.com/deploy/button.png)](https://heroku.com/deploy)

Just point your Twilio number's Messaging URL to `http://yourhost:PORT/message` and then any SMS sent to that number will result in a note being created in your Evernote Sandbox account. Also point your Twilio number's Voice URL to `http://yourhost:PORT/voice` and then call your Twilio number to create a voicemail note.

## Installation

Grab the source code:

```
$ git clone <this repo>
```

Change into the directory that was created and install the required gems using Bundler:

```
$ bundle install
```

Setup an environment variable to hold your Evernote API developer token:

```
$ export EVERNOTE_DEV_TOKEN=***YOUR_DEV_TOKEN_HERE***
```

Run the app with:

```
$ bundle exec thin start -R config.ru
```

To test locally you'll want to expose your localhost web server via a public address using something like [ngrok](https://ngrok.com/). 

Once you have that running, configure your Twilio number's Messaging URL to point at the `/message` endpoint and your Voice URL to point at the `/voice` endpoint in the running app. Now you can send an SMS/MMS to or call your Twilio number to create a note in your Evernote Sandbox account.

## Meta

* No warranty expressed or implied. Software is as is.
* [MIT License](http://www.opensource.org/licenses/mit-license.html)
* Made with ♥ by [Twilio](http://twilio.com) Philly
