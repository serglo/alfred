Alfred
======

Alfred is a chat application written in node.js with express.js and socket.io that uses couchdb to store information and everyauth (OAuth with facebook, twitter or github) for authentication.

Installation
------------

    $ git clone git@github.com:rendro/alfred.git alfred && cd alfred
    $ npm install
    $ make

You can start the app with [Foreman](http://blog.daviddollar.org/2011/05/06/introducing-foreman.html). Therefore you need to set up your `.env` file:

    $ cp .env.dist .env

And then fill in your app keys/secrets the app port and the session secret. You are ready to go:

    $ foreman start


Information
-----------

Currently there is a bug in one dependeny, the jscrollpane. Change line number `1392` from

    $("script",elem).filter('[type="text/javascript"],not([type])').remove();

to this:

    $("script",elem).filter('[type="text/javascript"]').remove();


Disclaimer
----------
This software is for testing reasons and far away from being deployable. Contribute by forking and send as much fancy pull requests as possible.
