# API Documentation

This document details the REST-like API. It includes the endpoints and example queries to interact with the server.

All requests and responses have the JSON mime type (`application/json`).

## Resources

The server provides access to four resources:

1. Users
2. Login
3. Sightings
4. Images

## Users

### GET `/biomap/users`

Returns an object with two keys, "status" and "users". "users" is an array of User objects.

### GET `/biomap/users?email=*`

Returns an object with two keys, "status" and "users". "users" is an array of User objects.

### GET `/biomap/users?email=<email>`

Returns an object with two keys, "status" and "users". "users" is an array containing a single User object with a matching email address.

If the email does not match, then a 404 is returned.

### GET `/biomap/users?user_id=*`

Returns an object with two keys, "status" and "users". "users" is an array of User objects.

### GET `/biomap/users?user_id=<id>`

Returns an object with two keys, "status" and "users". "users" is an array containing a single User object with a matching ID.

If the email does not match, then a 404 is returned.

### POST `/biomap/users`

Example body:

    {
     "email": "RANDOM@example.com",
     "passwd": "secret",
     "name": "DongWoo",
     "address": "Canada",
     "occupation": "worker",
     "year_hunting": 99
    }

Will create a new user, if all the keys are specified. If any keys are missing then a 400 is returned. If there is an error saving the User model, then a 500 is returned. If the user already exists, a 400 is returned.

### PUT `/biomap/users`

Example body:

    {
     "email": "RANDOM@example.com",
     "passwd": "secret",
     "name": "DongWoo",
     "address": "Canada",
     "occupation": "worker",
     "year_hunting": 3,
     "user_id": 10
    }

Will update the user with the matching user_id. If any keys are missing then a 400 is returned. If the user_id cannot be found then a 404 is returned.

### DELETE `/biomap/users`

    {
      "user_id": 10
    }

Deletes the user with the matching user_id. If the user_id is missing then a 400 is returned. If the user_id cannot be found then a 404 is returned.

## Login

### GET `/biomap/login?email=<email>&passwd=<password>`

Authenticates a user by their email and password. Note that this does not provide access control, only verification. If any keys are missing then a 400 is returned. If the email cannot be found then a 404 is returned. If the password does not match then a 401 is returned. Passwords are hashed using a SHA-256 hex digest.

## Sightings

### GET `/biomap/sightings?sighting_id=*&user_id=*`

Returns an object with two keys, "status" and "sightings". "sightings" is an array of Sighting objects. Matches all Sightings in the database.

### GET `/biomap/sightings?sighting_id=*&user_id=<id>`

Returns an object with two keys, "status" and "sightings". "sightings" is an array of Sighting objects. Matches all Sightings in the database that are tied to a specific user id.

### GET `/biomap/sightings?sighting_id=<sighting id>&user_id=<user id>`

Returns an object with two keys, "status" and "sightings". "sightings" is a single Sighting object. Matches the sighting with the specified id and user id. If no sighting is found then a 404 is returned.

### POST `/biomap/sightings`

Example body:

    {
     "user_id": $USER_ID,
     "animal_name": "caribou",
     "no_of_adults": 2,
     "no_of_calves": 1,
     "unusual_observations": "N/A",
     "lat": 100.0,
     "lon": 200.0,
     "visible_signs": ["A", "B", "C"],
     "photos": null
    }

Will create a new Sighting, if all the keys are specified. If any keys are missing then a 400 is returned.

### PUT `/biomap/sightings`

Example body:

    {
     "user_id": $USER_ID,
     "animal_name": "caribou",
     "no_of_adults": 2,
     "no_of_calves": 1,
     "unusual_observations": "N/A",
     "lat": 100.0,
     "lon": 200.0,
     "visible_signs": ["A", "B", "C"],
     "photos": null,
     "sighting_id": 5
    }

Will update an existing Sighting object. If any keys are missing then a 400 is returned. If the sighting_id does not match then a 404 is returned.

### DELETE `/biomap/sightings`

    {
      "sighting_id": 5
    }

Deletes the Sighting with the matching sighting_id. If the sighting_id is missing then a 400 is returned. If the sighting_id cannot be found then a 404 is returned.

## Images

### GET `/biomap/images?image_id=*&sighting_id=<id>`

Returns an object with two keys, "status" and "images". "images" is an array of Image objects. Retrieves all Images for a specific sighting_id. If any keys are missing then a 400 is returned.

### GET /biomap/images?image_id=<image id>&sighting_id=<id>

Returns an object with two keys, "status" and "images". "images" is an array of Image objects. Retrieves all Images for a specific sighting_id. "image_id" parameter is ignored. Returns a 404 is no images are found. If any keys are missing then a 400 is returned.

### POST `/biomap/images`

Example body:

    {
      "user_id": 10,
      "sighting_id": 5
    }

    HTTP Multipart: image_file => File to Upload

Creates a new Image object. If any keys are missing then a 400 is returned. If the image_file is not specified then a 400 is returned. Image is named with the user id and the md5 digest of the image file's contents and stored in `/tmp`.
