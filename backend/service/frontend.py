import json
import time
import hashlib

from tornado.web import RequestHandler
import db

class _BaseRequestHandler(RequestHandler):
    def options():
        self.set_header("Access-Control-Allow-Origin", "*")
        self.set_header('Access-Control-Allow-Methods', 'POST, GET, DELETE, PUT, OPTIONS')
        self.set_header('Access-Control-Allow-Headers', 'Origin, X-Requested-With, Content-Type, Accept')

class BaseRequestHandler(_BaseRequestHandler):
    def _args(self, r):
        if isinstance(r, dict):
            for k, v in r.items():
                print "[args: key]", k
                if isinstance(v, list) and len(v) == 0:
                    r[k] = []
                elif isinstance(v, list) and len(v) > 0:
                    r[k] = v[0]
                elif isinstance(v, basestring):
                    r[k] = v
        return r

    def args(self, default=None):
        r = self.request.arguments
        _ctype = self.request.headers.get("Content-Type", "")
        if _ctype.find("application/json") >= 0:
            _m = self.request.body
            if len(self.request.body) > 0:
                try:
                    _r = json.loads(self.request.body)
                except:
                    return {"_error": "not json"}
                r = self._args(r)
                r.update(_r)
                return r
        r = self._args(r)
        return r

    def checkParameter(self, reqargs, args):
        print reqargs
        print args.keys()
        return len(set(reqargs) - set(args.keys())) == 0

    def _return(self, d, code=200):
        self.set_status(code)
        return self.write(json.dumps(d))


class LoginHandler(BaseRequestHandler):
    def initialize(self):
        db._sess = db.openDB()
        self._db = db.BioMapUser(db._sess)

    def get(self):
        args = self.args()
        if not self.checkParameter(["email", "passwd"], args):
            return self._return({ "status": "error", "desc": "invalid parameters." }, 400)

        user = self._db.get_user(args["email"])
        if not user:
            return self._return({ "status": "error", "desc": "not found user" }, 404)

        if user.passwd == hashlib.sha256(args["passwd"]).hexdigest():
            return self._return({ "status": "ok", "desc": "authenticated" })
        else:
            return self._return({ "status": "error", "desc": "invalid password" }, 401)


class UsersHandler(BaseRequestHandler):
    def initialize(self):
        db._sess = db.openDB()
        self._db = db.BioMapUser(db._sess)

    def get(self):
        args = self.args()
        if not self.checkParameter(["email"], args):
            return self._return({ "status": "error", "desc": "invalid parameters." }, 400)

        if args["email"] == "*":
            # list users
            users = [ u.todict() for u in db.list_all(db.User) ]
        else:
            users = self._db.get_user(args["email"])
            if not users:
                return self._return({ "status": "error", "desc": "not found" }, 404)
            users = users.todict()

        return self._return({ "status":"ok", "users":users })

    def post(self):
        args = self.args()
        if not self.checkParameter(["email", "passwd", "name", "email", "address", "occupation", "year_hunting"], args):
            return self._return({ "status": "error", "desc": "invalid parameters." }, 400)

        uid = self._db.add_user(args["email"], args["passwd"], args["name"], args["address"], args["occupation"], args["year_hunting"])
        if uid == None:
            return self._return({ "status": "error", "desc": "cannot create" }, 500)

        if not uid:
            user = self._db.get_user(args["email"])
            uid = user.id
            return self._return({ "status": "error", "desc": "already exists", "user_id": uid }, 400)

        return self._return({ "status": "ok", "user_id": uid })

    def put(self):
        args = self.args()
        if not self.checkParameter(["user_id", "email", "passwd", "name", "email", "address", "occupation", "year_hunting"], args):
            return self._return({ "status": "error", "desc": "invalid parameters." }, 400)

        user = self._db.get_user_id(args["user_id"])
        if not user:
            return self._return({ "status": "error", "desc": "not found" }, 404)

        self._db.update_user_id(args["user_id"], args["email"], args["passwd"], args["name"], args["email"], args["address"], args["occupation"], args["year_hunting"])

        return self._return({ "status": "ok", "desc": "updated" })

    def delete(self):
        args = self.args()
        if not self.checkParameter(["user_id"], args):
            return self._return({ "status": "error", "desc": "invalid parameters." }, 400)

        user = self._db.get_user_id(args["user_id"])
        if not user:
            return self._return({ "status": "error", "desc": "not found" }, 404)

        self._db.delete_user(args["user_id"])
        return self._return({ "status": "ok", "user_id": args["user_id"], "desc": "deleted" })


class SightingsHandler(BaseRequestHandler):
    def initialize(self):
        db._sess = db.openDB()
        self._db = db.BioMapSighting(db._sess)

    def get(self):
        args = self.args()
        if not self.checkParameter(["user_id", "sighting_id"], args):
            return self._return({ "status": "error", "desc": "invalid parameters." }, 400)

        if args["sighting_id"] == "*" and args["user_id"] == "*":
            # list sightings
            sightings = [ s.todict() for s in db.list_all(db.Sighting) ]
        elif args["sighting_id"] == "*":
            sightings = [ s.todict() for s in self._db.get_sighting_user(args["user_id"]) ]
        else:
            sightings = self._db.get_sighting_id(args["sighting_id"])
            if not sightings:
                return self._return({ "status": "error", "desc": "not found" }, 404)
            sightings = sightings.todict()

        return self._return({ "status":"ok", "sightings":sightings })

    def post(self):
        args = self.args()
        if not self.checkParameter(["user_id", "animal_name", "no_of_adults", "no_of_calves", "unusual_observations", "lat", "lon", "visible_signs", "photos"], args):
            return self._return({ "status": "error", "desc": "invalid parameters." }, 400)

        sid = self._db.add_sighting(args["animal_name"], int(args["no_of_adults"]), int(args["no_of_calves"]), args["unusual_observations"], float(args["lat"]), float(args["lon"]), args["visible_signs"], args["user_id"])
        return self._return({ "status": "ok", "sighting_id": sid })

    def put(self):
        args = self.args()
        if not self.checkParameter(["user_id", "animal_name", "sighting_id", "no_of_adults", "no_of_calves", "unusual_observations", "lat", "lon", "visible_signs", "photos"], args):
            return self._return({ "status": "error", "desc": "invalid parameters.", "args": args }, 400)

        sighting = self._db.get_sighting_id(args["sighting_id"])
        if not sighting:
            return self._return({ "status": "error", "desc": "not found" }, 404)

        self._db.update_sighting_id(args["sighting_id"], args["animal_name"], args["no_of_adults"], args["no_of_calves"], args["unusual_observations"], args["lat"], args["lon"], args["visible_signs"], args["user_id"])

        return self._return({ "status": "ok", "desc": "updated" })

    def delete(self):
        args = self.args()
        if not self.checkParameter(["sighting_id"], args):
            return self._return({ "status": "error", "desc": "invalid parameters." }, 400)

        sighting = self._db.get_sighting_id(args["sighting_id"])
        if not sighting:
            return self._return({ "status": "error", "desc": "not found" }, 404)

        self._db.delete_sighting(args["sighting_id"])
        return self._return({ "status": "ok", "sighting_id": args["sighting_id"], "desc": "deleted" })


class ImagesHandler(BaseRequestHandler):
    def initialize(self):
        db._sess = db.openDB()
        self._db = db.BioMapImage(db._sess)

    def get(self):
        args = self.args()
        if not self.checkParameter(["sighting_id", "image_id"], args):
            return self._return({ "status": "error", "desc": "invalid parameters.", "args": args }, 400)

        if args["image_id"] == "*":
            # list images
            images = [ s.todict() for s in self._db.get_images_sighting(args["sighting_id"]) ]
        else:
            images = self._db.get_image_id(args["sighting_id"])
            if not images:
                return self._return({ "status": "error", "desc": "not found" }, 404)
            images = images.todict()

        return self._return({ "status":"ok", "images":images })

    def post(self):
        args = self.args()

        if not self.checkParameter(["user_id", "sighting_id"], args):
            return self._return({ "status": "error", "desc": "invalid parameters.", "args": args }, 400)

        if "image_file" in self.request.files:
            image_file = self.request.files["image_file"][0]["body"]
        else:
            return self._return({ "status": "error", "desc": "invalid parameters." }, 400)

        path = "/tmp/images/"+args["user_id"]+"-"+hashlib.md5(image_file).hexdigest()+".jpg"
        with open(path, "wb") as fp:
            fp.write(image_file)

        iid = self._db.add_image(path, args["sighting_id"], args["user_id"])
        return self._return({ "status": "ok", "image_id": iid })
