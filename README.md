# Note Taking On The Go With Twilio and the Evernote API

This is the code repo for a blog post on how your can Twilio and the Evernote API to allow you to create a note in Evernote from a text message. I highly encourage you to walk through the entire tutorial to get this software up-and-running on a server of your choice.

If you have any questions or run into a problem, please feel free to file an issue. 

Thanks!

## Setup

Here's what you'll need to get started:

* A [Twilio](http://twilio.com) account that can send and receive SMS messages - [create one free here](http://twilio.com/try-twilio)
* [Evernote API and Developer Key](https://dev.evernote.com/#apikey)
* [Evernote Sandbox Account](http://sandbox.evernote.com)

The blog post that accompanies this repo describes how to set up the developer key and Evernote Sandbox account.

If you want to jump right into using this right now, use the Heroku Button below:


Now you can send an SMS to your Twilio number and a note will be created in your Evernote Sandbox account with the text from the SMS!

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

Once you have that running, configure your Twilio number's Messaging URL to point at the `/message` endpoint in the running app. Now you can send an SMS to your Twilio number to create a note in your Evernote Sandbox account.

## Meta

* No warranty expressed or implied. Software is as is.
* [MIT License](http://www.opensource.org/licenses/mit-license.html)
* Made with ♥ by [Twilio](http://twilio.com) Philly
