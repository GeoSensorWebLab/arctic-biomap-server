# Arctic Bio Map Server v2

This is the server backend code that is used for communicating with the Arctic Bio Map (ABM) mobile client.

It is also used by the ABM Front-End Portal for visualizing the sightings information for researchers.

This server is written in Python 2.7.

## Development

Checkout a copy of the [repository from BitBucket](https://bitbucket.org/geosensorweblab/arctic-biomap-server). Install Python 2.7 on your system if it is not already; Linux and Mac OS X may already have a copy installed.

Then install `tornado` and `sqlalchemy`.

    $ pip install tornado
    $ pip install sqlalchemy

Start up a local server with:

    $ cd backend
    $ python server.py DATABASE_URL="" COOKIE=""

`DATABASE_URL` must be a database connection URL like `mysql://USER:PASS@HOST/DB`. `COOKIE` must be a random hex string. If COOKIE changes, then all users signed into the server through their browser will be logged out.

## Tests

Tests are available in the `backend/tests` directory. They are Shell scripts so will only work on Mac/Unix systems.

## abm-server.conf

This is a configuration file for Upstart on Ubuntu. Edit the file to point to the location of your production installation and then install the file in `/etc/init`. Then you can control the server with `initctl`:

    $ sudo initctl status abm-server
    $ sudo initctl start abm-server
    $ sudo initctl stop abm-server
    $ sudo initctl restart abm-server

The script will also automatically start the server when the host starts up.

## License

Copyright GeoSensorWeb Lab 2015, All Rights Reserved.
