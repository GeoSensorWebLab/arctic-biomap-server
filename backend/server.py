#!/usr/bin/env python

import time
import os
import sys
import logging
import tornado.httpserver
import tornado.ioloop
import tornado.web
import json
import urllib
import os
import time
import sys

from service.frontend import LoginHandler
from service.frontend import UsersHandler
from service.frontend import SightingsHandler
from service.frontend import ImagesHandler


bind_ip = "0.0.0.0"
settings = {
    "static_path": os.path.join(os.path.dirname(__file__), "www/static"),
    "template_path": os.path.join(os.path.dirname(__file__), "www/template"),
    "cookie_secret": os.getenv('COOKIE', ''),
    "debug": True,
}

application = tornado.web.Application([
    # (r"/static/(.*)", tornado.web.StaticFileHandler, dict(path=settings['static_path'])),
    (r"/biomap/login", LoginHandler),
    (r"/biomap/users", UsersHandler),
    (r"/biomap/sightings", SightingsHandler),
    (r"/biomap/images", ImagesHandler),
], **settings)

def main(ip, port):
    http_server = tornado.httpserver.HTTPServer(application)
    http_server.listen(port, ip)
    print("Starting HTTP Server on %s:%i" % (ip, port))
    tornado.ioloop.IOLoop.instance().start()

if __name__ == "__main__":
    try:
        port = int(sys.argv[1])
    except:
        port = 8081

    main(bind_ip, port)
