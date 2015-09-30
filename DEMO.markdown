# Demo Service

A demonstration instance of Arctic Bio Map Server is online for testing as an API-only service (it does not include a web user interface).

* [http://abm-demo.arcticconnect.org/biomap](http://abm-demo.arcticconnect.org/biomap)

The database is automatically reset every hour.

Here are some test queries you can run with [curl](http://curl.haxx.se).

### Get All Users

    $ curl -s -H "Content-Type: application/json" -XGET "http://abm-demo.arcticconnect.org/biomap/users"

### Get All Sightings

    $ curl -s -H "Content-Type: application/json" -XGET "http://abm-demo.arcticconnect.org/biomap/sightings?sighting_id=*&user_id=*"

### Create a User

    $ cat > tmp_user << _EOF_
    {
    	"email": "random@example.com",
    	"passwd": "secret",
    	"name": "Me",
    	"address": "Canada",
    	"occupation": "worker",
    	"year_hunting": 99
    }
    _EOF_

    $ curl -s -H "Content-Type: application/json" -XPOST --data @tmp_user "http://abm-demo.arcticconnect.org/biomap/users"

### Create a Sighting

    $ cat > tmp_sighting << _EOF_
    {
    	"user_id": 1,
    	"animal_name": "caribou",
    	"no_of_adults": 2,
    	"no_of_calves": 1,
    	"unusual_observations": "N/A",
    	"lat": 51.0,
    	"lon": -114.0,
    	"visible_signs": ["A", "B", "C"],
    	"photos": null
    }
    _EOF_

    $ curl -s -H "Content-Type: application/json" -XPOST --data @tmp_sighting "http://abm-demo.arcticconnect.org/biomap/sightings"
