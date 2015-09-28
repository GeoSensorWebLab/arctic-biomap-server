# Change Log

## [2.3] - 2015-09-04

* Added API for accessing users by `user_id`
* Removed un-needed logging statements
* Removed manual conversion to JSON and let Tornado do the conversion automatically

## [2.2] - 2015-08-27

* Fixed typos in error messages
* Switched to letting the database handle auto-increment
* Updated test scripts with better output
* Fixed loading of ENV variables for Upstart script

## [2.1] - 2015-08-26

* Added support for loading sensitive data from ENV
* Added Upstart script for automatically starting the service on Ubuntu servers
* Fixed columns for user to not be limited to 16 characters
* Switched to unix line endings for consistency

## [2.0] - 2015-01-21

* Backend switched to Python
* Designed to work with second prototype of Mobile Client

## [1.0] - 2014-09-29

* Initial prototype for Arctic Bio Map Server in Java
* Receives data from Arctic Bio Map Mobile Client prototype
